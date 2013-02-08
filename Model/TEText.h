//
//  TEText.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEText : NSObject

@property (nonatomic, assign) NSUInteger identifie;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *dateString;

+ (NSArray *)allTexts;

+ (void)saveText:(TEText *)text;

+ (TEText *)newTextBasedOnDatabase;

+ (TEText *)textWithIdentifie:(NSUInteger)identifie;

+ (TEText *)textWithJsonObject:(NSDictionary *)jsonObject;

+ (void)deleteTextOfIdentifie:(NSUInteger)identifie;

- (NSDictionary *)jsonObject;

- (void)finalizeContent;

@end
