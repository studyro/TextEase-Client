//
//  NSString+QueryParams.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QueryParams)

+ (NSString *)queryStringWithParams:(NSDictionary *)params;

- (NSDictionary *)paramsDictionary;

@end
