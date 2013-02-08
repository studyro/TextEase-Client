//
//  TESupporterProtocol.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-12.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEConnection;
@protocol TESupporterProtocol <NSObject>

- (void)resetInnerStatus;
- (void)acceptBaseInfo:(id)info;
- (TEConnection *)correspondedConnection;

@end
