//
//  TECommandCenter.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-13.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TECommandCenter.h"
#import "NSString+QueryParams.h"

static TECommandCenter *instance = nil;

@interface TECommandCenter ()

@end

@implementation TECommandCenter

+ (TECommandCenter *)sharedCommandCenter
{
    if (!instance) {
        instance = [[TECommandCenter alloc] init];
    }
    
    return instance;
}

- (void)dealloc
{
    [_currentVersion release];
    
    [super dealloc];
}

- (void)_editText:(TEText *)text ofCommand:(kTECommand)command
{
    if (command == kTECommandDelete) {
        [TEText deleteTextOfIdentifie:text.identifie];
    }
    else {
        [TEText saveText:text];
    }
}

- (NSString *)_commandStringWithCommand:(kTECommand)command
{
    NSString *stringToReturn = nil;
    switch (command) {
        case kTECommandDelete:
            stringToReturn = @"delete";
            break;
        
        case kTECommandCreate:
            stringToReturn = @"create";
            break;
            
        case kTECommandUpdate:
            stringToReturn = @"update";
            break;
            
        default:
            break;
    }
    
    return stringToReturn;
}

- (void)executeCommand:(kTECommand)command toText:(TEText *)text
{
    // check newest version
    // if has one that isn't synced yet, append to it
    // else create a new version
    
    [self _editText:text ofCommand:command];
    
    TEVersion *newestVersion = [TEVersion newestVersion];
    if (newestVersion.syncedWithServer || newestVersion.toVersion == 0) {
        NSDictionary *changesVectorDic = @{[NSNumber numberWithUnsignedInteger:text.identifie] : [self _commandStringWithCommand:command]};
        [TEVersion createVersionOfVector:changesVectorDic];
    }
    else if (newestVersion && !newestVersion.syncedWithServer) {
        [TEVersion appendNewestVersionOfVector:@{[NSNumber numberWithUnsignedInteger:text.identifie] : [self _commandStringWithCommand:command]}];
//        _currentVersion = [[TEVersion newestVersion] retain];
    }
    
    TEVersion *version = [TEVersion newestVersion];
    NSLog(@"now Version : f: %d, t: %d, c: %@, s: %d", version.fromVersion, version.toVersion, version.changesVector, version.syncedWithServer);
}

@end
