//
//  TEConnection.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEConnection;
@protocol TEConnectionDelegate <NSObject>

- (void)connection:(TEConnection *)connection didFinishedWithJsonObj:(id)jsonObj;
- (void)connection:(TEConnection *)connection didFailWithError:(NSError *)error;

@end

@interface TEConnection : NSObject

@property (nonatomic, assign) id<TEConnectionDelegate> delegate;

- (instancetype)initWithURL:(NSString *)urlString
                queryParams:(NSDictionary *)params
                 httpMethod:(NSString *)httpMethod
                 httpHeader:(NSDictionary *)header
                   httpBody:(NSDictionary *)body;

+ (instancetype)connectionWithURL:(NSString *)urlString
                      queryParams:(NSDictionary *)params
                       httpMethod:(NSString *)httpMethod
                       httpHeader:(NSDictionary *)header
                         httpBody:(NSDictionary *)body;

- (void)start;
- (void)cancel;

@end
