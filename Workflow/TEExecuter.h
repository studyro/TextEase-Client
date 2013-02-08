//
//  TEExecuter.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-12.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEText.h"
#import "TEVersion.h"

@class TEExecuter;
@protocol TEExecuterDelegate <NSObject>

- (void)executer:(TEExecuter *)executer didCompleteStepWithInfo:(NSDictionary *)info;

- (void)executer:(TEExecuter *)executer didFinisheSyncWithInfo:(NSDictionary *)info;

@end

@interface TEExecuter : NSObject

@property (nonatomic, assign) id<TEExecuterDelegate> delegate;

- (void)sync;

@end
