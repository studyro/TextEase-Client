//
//  TECheckSupporter.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-12.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TECheckSupporter.h"
#import "TEConnection.h"
#import "TEApi.h"
#import "TEVersion.h"

@interface TECheckSupporter ()

@end

@implementation TECheckSupporter

- (void)resetInnerStatus
{
    // no private params to reset;
}

- (void)acceptBaseInfo:(id)info
{
    // accept nothing as the first step
}

- (TEConnection *)correspondedConnection
{
    TEVersion *newestVersion = [TEVersion newestVersion];
    TEConnection *connection = [TEConnection connectionWithURL:kCheckSyncStatusAPI queryParams:nil httpMethod:@"POST" httpHeader:nil httpBody:[newestVersion jsonObject]];
    
    return connection;
}

@end
