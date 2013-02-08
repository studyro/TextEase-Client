//
//  NSString+QueryParams.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "NSString+QueryParams.h"

@implementation NSString (QueryParams)

+ (NSString *)queryStringWithParams:(NSDictionary *)params
{
    if (!params || ![[params allKeys] count])
        return @"";
    
    NSMutableString *queryString = [NSMutableString string];
    
    __block BOOL beginning = YES;
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (beginning) [queryString appendFormat:@"%@=%@", key, obj];
        else [queryString appendFormat:@"&%@=%@", key, obj];
        
        beginning = NO;
    }];
    
    return queryString;
}

- (NSDictionary *)paramsDictionary
{
    NSArray *keyValuePairs = [self componentsSeparatedByString:@"&"];
    
    __block NSMutableDictionary *params = nil;
    if ([keyValuePairs count]) {
        params = [NSMutableDictionary dictionary];
        
        [keyValuePairs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSArray *arr = [obj componentsSeparatedByString:@"="];
            [params setObject:[arr objectAtIndex:1] forKey:[arr objectAtIndex:0]];
        }];
    }
    
    return params?[NSDictionary dictionaryWithDictionary:params]:nil;
}

@end
