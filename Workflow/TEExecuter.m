//
//  TEExecuter.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-12.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEExecuter.h"
#import "TEConnection.h"
#import "TECheckSupporter.h"
#import "TEPostSupporter.h"
#import "TEGetSupporter.h"
#import "TEFinishSupporter.h"

typedef enum {
    kTESyncStatusUndefined = 0,
    kTESyncStatusUpload = 1,
    kTESyncStatusDownload = 2,
    kTESyncStatusCommunicate = 3,
    kTESyncStatusSynced = 4
}kTESyncStatus;

@interface TEExecuter () <TEConnectionDelegate>
{
    NSUInteger _currentStep; // start from 0
    NSUInteger _stepCount; // 3 for purely upload/download, 4 for comlex case
    kTESyncStatus _syncStatus;
}

@property (nonatomic, retain) NSMutableArray *supporterArray;
@property (nonatomic, retain) NSMutableArray *connectionQueue;

@end

@implementation TEExecuter

- (void)dealloc
{
    [_supporterArray release];
    [_connectionQueue release];
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        _currentStep = 0;
        _stepCount = 4;
        
        _supporterArray = [[NSMutableArray alloc] initWithCapacity:4];
        _connectionQueue = [[NSMutableArray alloc] initWithCapacity:2];
        
        TECheckSupporter *checkSupporter = [[TECheckSupporter alloc] init];
        TEGetSupporter *getSupporter = [[TEGetSupporter alloc] init];
        TEPostSupporter *postSupporter = [[TEPostSupporter alloc] init];
        TEFinishSupporter *finishSupporter = [[TEFinishSupporter alloc] init];
        
        [_supporterArray addObject:checkSupporter];
        [_supporterArray addObject:getSupporter];
        [_supporterArray addObject:postSupporter];
        [_supporterArray addObject:finishSupporter];
        
        [checkSupporter release];
        [getSupporter release];
        [postSupporter release];
        [finishSupporter release];
    }
    
    return self;
}

- (void)sync
{
    [self resetStatus];
    if ([self.connectionQueue count]) [self.connectionQueue removeAllObjects];
    if ([TEVersion newestVersion].syncedWithServer) return;
    
    [self _addConnectionByCurentSupporterInfo:nil forStep:0];
    TEConnection *connection = [self _currentConnection];
    [connection start];
}

- (void)resetStatus
{
    _currentStep = 0;
    if ([self.connectionQueue count])
        [self.connectionQueue removeAllObjects];
    
}

#pragma mark - Helpers

- (TEConnection *)_connectionWithSupporterInfo:(id)info forStep:(NSUInteger)step
{
    if (step > _stepCount - 1) return nil;
    
    id<TESupporterProtocol> supporter = [self.supporterArray objectAtIndex:step];
    
    [supporter acceptBaseInfo:info];
    TEConnection *connection = [supporter correspondedConnection];
    
    if (!connection) NSLog(@"maybe suppoter didn't accept info");
    else connection.delegate = self;
    return connection;
}

- (void)_addConnectionByCurentSupporterInfo:(id)info forStep:(NSUInteger)step
{
    TEConnection *connection = [self _connectionWithSupporterInfo:info forStep:step];
    if (!connection) return;
    
    [self.connectionQueue addObject:connection];
}

- (void)_insertConnectionWithSupporterInfo:(id)info forStep:(NSUInteger)step
{
    TEConnection *connection = [self _connectionWithSupporterInfo:info forStep:step];
    if (!connection) return;
    
    [self.connectionQueue insertObject:connection atIndex:0];
}

- (TEConnection *)_currentConnection
{
    if ([self.connectionQueue count])
        return [self.connectionQueue objectAtIndex:0];
    else
        return nil;
}

- (void)_dequeueConnection
{
    if ([self.connectionQueue count])
        [self.connectionQueue removeObjectAtIndex:0];
}

- (void)_defineStatusByString:(NSString *)syncAct
{
    if ([syncAct isEqualToString:@"upload"]) _syncStatus = kTESyncStatusUpload;
    else if ([syncAct isEqualToString:@"download"]) _syncStatus = kTESyncStatusDownload;
    else if ([syncAct isEqualToString:@"communicate"]) _syncStatus = kTESyncStatusCommunicate;
    else if ([syncAct isEqualToString:@"synced"]) _syncStatus = kTESyncStatusSynced;
    else _syncStatus = kTESyncStatusUndefined;
}

- (void)_notifyDelegateForFinishing:(NSDictionary *)info
{
    if ([self.delegate respondsToSelector:@selector(executer:didFinisheSyncWithInfo:)]) {
        [self.delegate executer:self didFinisheSyncWithInfo:info];
    }
}

- (BOOL)_shouldSkipThisStep
{
    return (_syncStatus == kTESyncStatusCommunicate) && (_currentStep == 2);
}

#pragma mark - TEConnection Delegate Methods
- (void)connection:(TEConnection *)connection didFinishedWithJsonObj:(id)jsonObj
{
    NSLog(@"------------response:\n%@", jsonObj);
    _currentStep++;
    [self _dequeueConnection];
    if (_currentStep == 1) {
        // get the sync header info
        [self _defineStatusByString:[jsonObj objectForKey:@"sync_act"]];
        if (_syncStatus == kTESyncStatusUpload) {
            // only safe uploading is needed, skip step 2
            _currentStep++;
        }
        else if (_syncStatus == kTESyncStatusCommunicate) {
            // both download and upload
            [self _insertConnectionWithSupporterInfo:jsonObj forStep:_currentStep+1];
        }
        else if (_syncStatus == kTESyncStatusSynced) {
            // data was perfectly synced, skip to last step
            _currentStep = _stepCount - 1;
            
            [self _notifyDelegateForFinishing:@{@"sync_status" : @"synced"}];
        }
    }
    else if (_currentStep == 2) {
        // get the newer text array
        if (_syncStatus == kTESyncStatusDownload) {
            // pure download case should skip POST step
            _currentStep++;
        }
        
        if ([jsonObj isKindOfClass:[NSArray class]] && [jsonObj count]) {
            NSArray *textJsonObjArray = (NSArray *)jsonObj;
            [textJsonObjArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                TEText *text = [TEText textWithJsonObject:obj];
                [TEText saveText:text];
            }];
        }
        
        [self _notifyDelegateForFinishing:@{@"sync_status" : @"got"}];
    }
    else if (_currentStep == 3) {
        // deal POST case response data
    }
    else if (_currentStep == _stepCount) {
        // finish the sync and get the newest version info
        TEVersion *newestVersion = [TEVersion versionWithJsonObject:jsonObj];
        newestVersion.syncedWithServer = YES;
        [TEVersion insertVersion:newestVersion];
    }
    
    if (![self _shouldSkipThisStep])
        [self _insertConnectionWithSupporterInfo:jsonObj forStep:_currentStep];
    
    TEConnection *nextConnection = nil;
    if ((nextConnection = [self _currentConnection])) [nextConnection start];
}

- (void)connection:(TEConnection *)connection didFailWithError:(NSError *)error
{
    // temporarily do nothing
}

@end
