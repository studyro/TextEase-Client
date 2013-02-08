//
//  TEGetSupporter.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-13.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEGetSupporter.h"
#import "TEConnection.h"
#import "TEApi.h"
#import "TEText.h"
#import "NSString+QueryParams.h"

@interface TEGetSupporter ()

@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSMutableDictionary *queryParams;

@end

@implementation TEGetSupporter

- (void)dealloc
{
    [_urlString release];
    [_queryParams release];
    
    [super dealloc];
}

- (void)resetInnerStatus
{
    self.urlString = nil;
    self.queryParams = nil;
}

- (void)acceptBaseInfo:(id)info
{
    NSString *getQueryString = [info objectForKey:@"get"];
    if (getQueryString && getQueryString.length) {
        _urlString = kGet_Specific_IdsAPI;
        NSMutableDictionary *getDic = [[[getQueryString paramsDictionary] mutableCopy] autorelease];
        for (id key in [getDic allKeys]) {
            id obj = [getDic objectForKey:key];
            if ([obj isEqualToString:@"delete"]) {
                // has /the/ NO potential of error
                // cause the server will return the vector with DELETE infos
                // Resolution: add a nil check
                [TEText deleteTextOfIdentifie:[key integerValue]];
                [getDic removeObjectForKey:key];
            }
        }
        
        if ([[getDic allKeys] count]) {
            self.queryParams = [NSMutableDictionary dictionary];
            __block NSUInteger idx = 1;
            [getDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *keyInParams = [NSString stringWithFormat:@"%u", idx++];
                [self.queryParams setObject:key forKey:keyInParams];
            }];
        }
    }
}

- (TEConnection *)correspondedConnection
{
    TEConnection *connection = [TEConnection connectionWithURL:self.urlString queryParams:self.queryParams httpMethod:@"GET" httpHeader:nil httpBody:nil];
    
    return connection;
}

@end
