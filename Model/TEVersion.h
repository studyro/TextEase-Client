//
//  TEVersion.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEVersion : NSObject

@property (nonatomic, assign) NSUInteger fromVersion;
@property (nonatomic, assign) NSUInteger toVersion;
@property (nonatomic, retain) NSString *changesVector;
@property (nonatomic, assign) BOOL syncedWithServer;

+ (TEVersion *)newestVersion;

+ (TEVersion *)versionWithJsonObject:(NSDictionary *)jsonObject;

+ (void)insertVersion:(TEVersion *)version;

+ (TEVersion *)createVersionOfVector:(NSDictionary *)vectorDic; // auto fill fromVersion toVersion

+ (void)appendNewestVersionOfVector:(NSDictionary *)additionalVector;

- (NSDictionary *)jsonObject;

@end
