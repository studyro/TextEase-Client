//
//  TEConnection.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEConnection.h"
#import "NSString+QueryParams.h"

@interface TEConnection () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSMutableURLRequest *_request;
    NSURLConnection *_connection;
    NSMutableData *_jsonData;
}
@end

@implementation TEConnection

- (instancetype)initWithURL:(NSString *)urlString queryParams:(NSDictionary *)params httpMethod:(NSString *)httpMethod httpHeader:(NSDictionary *)header httpBody:(NSDictionary *)body
{
    if (self = [super init]) {
        NSURL *url = nil;
        if (params)
            url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@?%@", urlString, [NSString queryStringWithParams:params]]];
        else
            url = [[NSURL alloc] initWithString:urlString];
            
        _request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:300];
        [url release];
        
        [_request setHTTPMethod:httpMethod];
        
        if (header)
            [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [_request setValue:obj forHTTPHeaderField:key];
            }];
        else
            [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if ([httpMethod isEqualToString:@"POST"]) {
            NSData *bodyData = nil;
            if (body) {
                bodyData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
            }
            [_request setHTTPBody:bodyData];
        }
        NSLog(@"url : %@, header: %@\n body: %@", url, _request.allHTTPHeaderFields, body);
    }
    
    return self;
}

+ (instancetype)connectionWithURL:(NSString *)urlString queryParams:(NSDictionary *)params httpMethod:(NSString *)httpMethod httpHeader:(NSDictionary *)header httpBody:(NSDictionary *)body
{
    return [[[[self class] alloc] initWithURL:urlString queryParams:params httpMethod:httpMethod httpHeader:header httpBody:body] autorelease];
}

- (void)start
{
    if (!_connection) _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
    else; // should throw error
    
    [_connection start];
}

- (void)cancel
{
    if (_connection) {
        [_connection cancel];
        [_connection release];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"url: %@\n body:%@", _request.URL, _request.HTTPBody];
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_jsonData) _jsonData = [[NSMutableData alloc] init];
    
    [_jsonData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id obj = nil;
    if ([_jsonData length]) obj = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingAllowFragments error:nil];
    
    if ([self.delegate respondsToSelector:@selector(connection:didFinishedWithJsonObj:)]) {
        [self.delegate connection:self didFinishedWithJsonObj:obj];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.delegate connection:self didFailWithError:error];
    }
}

@end
