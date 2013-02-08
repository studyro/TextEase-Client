//
//  TECommandCenter.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-13.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEText.h"
#import "TEVersion.h"

typedef enum {
    kTECommandCreate = 0,
    kTECommandUpdate = 1,
    kTECommandDelete = 2
}kTECommand;

@interface TECommandCenter : NSObject

@property (nonatomic, readonly) TEVersion *currentVersion;

+ (TECommandCenter *)sharedCommandCenter;

- (void)executeCommand:(kTECommand)command toText:(TEText *)text;

@end
