//
//  TEFinishSupporter.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-13.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEFinishSupporter.h"
#import "TEConnection.h"
#import "TEApi.h"
#import "TEText.h"

@implementation TEFinishSupporter

- (void)resetInnerStatus
{
    
}

// analyze get&post result here
- (void)acceptBaseInfo:(id)info
{
    
}

- (TEConnection *)correspondedConnection
{
    TEConnection *connection = [TEConnection connectionWithURL:kFinishStatusAPI queryParams:nil httpMethod:@"GET" httpHeader:nil httpBody:nil];
    
    return connection;
}

@end
