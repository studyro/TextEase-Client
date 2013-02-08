//
//  TEUpdateSupporter.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-12.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEPostSupporter.h"
#import "TEApi.h"
#import "TEText.h"
#import "TEVersion.h"
#import "NSString+QueryParams.h"
#import "TEConnection.h"

typedef enum {
    kUpdateMethodNone = 0,
    kUpdateMethodUpload = 1,
    kUpdateMethodCommunicate = 2
}kUpdateMethod;

@interface TEPostSupporter ()
{
    kUpdateMethod _updateMethod;
}
@property (nonatomic, retain) NSDictionary *versionInfo;
@property (nonatomic, assign) NSUInteger serverVersion;
@end

@implementation TEPostSupporter

- (void)dealloc
{
    [_versionInfo release];
    
    [super dealloc];
}
/*
{
 sync_act : upload/download/communicate/synced
 version :
 collision : safe/unsafe
 (if unsafe)
 (post : 4=create&1=create)
 (get : 2=delete&3=change)
}
*/
- (void)resetInnerStatus
{
    self.versionInfo = nil;
}

- (void)acceptBaseInfo:(id)info
{
    self.serverVersion = [[info objectForKey:@"version"] integerValue];
    if ([[info objectForKey:@"collision"] isEqualToString:@"safe"])
        self.versionInfo = [[TEVersion newestVersion] jsonObject];
    else // unsafe
        self.versionInfo = @{@"changesVector" : [info objectForKey:@"post"]};
}

- (void)pushKey:(NSString *)identifie value:(NSString *)change intoBodyParams:(NSMutableDictionary *)bodyParams
{
    NSMutableArray *specificChangeArray = [bodyParams objectForKey:change];
    if (!specificChangeArray) {
        specificChangeArray = [NSMutableArray array];
        [bodyParams setObject:specificChangeArray forKey:change];
    }
    
    if ([change isEqualToString:@"delete"]) {
        NSUInteger identifieInteger = [identifie integerValue];
        NSDictionary *keyValuePair = @{@"id" : [NSNumber numberWithInteger:identifieInteger]};
        [specificChangeArray addObject:keyValuePair];
    }
    else {
        TEText *text = [TEText textWithIdentifie:[identifie integerValue]];
        [specificChangeArray addObject:[text jsonObject]];
    }
}

- (NSDictionary *)bodyParams
{
    NSMutableDictionary *bodyParams = [NSMutableDictionary dictionary];
    
    [bodyParams setObject:self.versionInfo forKey:@"versionInfo"];
    NSString *changesVector = [self.versionInfo objectForKey:@"changesVector"];
    if (changesVector && changesVector.length) {
        NSDictionary *changesDic = [changesVector paramsDictionary];
        
        [changesDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            [self pushKey:key value:obj intoBodyParams:bodyParams];
        }];
    }
    
    return bodyParams;
}

- (TEConnection *)correspondedConnection
{
    NSString *urlString = kUpdateAPI;
    
    TEConnection *connection = [TEConnection connectionWithURL:urlString queryParams:nil httpMethod:@"POST" httpHeader:nil httpBody:[self bodyParams]];
    
    return connection;
}

@end
