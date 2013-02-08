//
//  NSDateFormatter+RFC3339.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "NSDateFormatter+RFC3339.h"

@implementation NSDateFormatter (RFC3339)

+ (NSDateFormatter *)rfc3339Formatter
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDateFormatter *rfc3339Formatter = [[NSDateFormatter alloc] init];
    [rfc3339Formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339Formatter setLocale:locale];
    [locale release];
    [rfc3339Formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [rfc3339Formatter autorelease];
}

@end
