//
//  TEText.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEText.h"
#import "EGODatabase.h"

static EGODatabase *database = nil;

@implementation TEText

+ (EGODatabase *)textDatabase;
{
    if (!database) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        NSString *databasePath = [docPath stringByAppendingPathComponent:@"text.db"];
        
        database = [[EGODatabase alloc] initWithPath:databasePath];
        
        NSString *tableSql = @"CREATE TABLE IF NOT EXISTS textTable(id INTEGER PRIMARY KEY, title TEXT, content TEXT)";
        
        [database executeUpdate:tableSql];
    }
    
    return database;
}

+ (TEText *)textWithJsonObject:(NSDictionary *)jsonObject
{
    TEText *text = [[TEText alloc] init];
    
    text.identifie = [[jsonObject objectForKey:@"id"] integerValue];
    text.title = [jsonObject objectForKey:@"title"];
    text.content = [jsonObject objectForKey:@"content"];
    
    return [text autorelease];
}

+ (TEText *)textWithIdentifie:(NSUInteger)identifie
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM textTable WHERE id = %d", identifie];
    
    EGODatabaseResult *result = [[TEText textDatabase] executeQuery:sql];
    
    if ([result count]) {
        EGODatabaseRow *row = [result rowAtIndex:0];
        TEText *text = [[TEText alloc] init];
        text.identifie = [row intForColumn:@"id"];
        NSString *title = [row stringForColumn:@"title"];
        NSString *content = [row stringForColumn:@"content"];
        text.title = [title isEqualToString:@"(null)"]?@"":title;
        text.content = [title isEqualToString:@"(null)"]?@"":content;
        
        return [text autorelease];
    }
    else
        return nil;
}

+ (void)deleteTextOfIdentifie:(NSUInteger)identifie
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM textTable WHERE id = %d", identifie];
    [[TEText textDatabase] executeUpdate:sql];
}

+ (NSArray *)allTexts
{
    NSString *sql = @"SELECT * FROM textTable";
    
    EGODatabaseResult *result = [[TEText textDatabase] executeQuery:sql];
    NSMutableArray *arr = [NSMutableArray array];
    for (EGODatabaseRow *row in result) {
        TEText *text = [[TEText alloc] init];
        text.identifie = [row intForColumn:@"id"];
        NSString *title = [row stringForColumn:@"title"];
//        NSString *content = [row stringForColumn:@"content"];
        text.title = [title isEqualToString:@"(null)"]?@"":title;
//        text.content = [title isEqualToString:@"(null)"]?@"":content;
        
        [arr addObject:text];
        [text release];
    }
    
    return arr;
}

+ (void)saveText:(TEText *)text
{
    if (text.identifie == 0) {
        text.identifie = [[self class] identifieGenerator];
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO textTable ('id', 'title', 'content') VALUES (%d, '%@', '%@')", text.identifie, text.title, text.content];
    
    [[TEText textDatabase] executeUpdate:sql];
}

+ (TEText *)newTextBasedOnDatabase
{
    TEText *text = [[TEText alloc] init];
    text.identifie = [[TEText class] identifieGenerator];
    text.title = @"";
    text.content = @"";
    
    [[TEText class] saveText:text];
    
    return [text autorelease];
}

+ (NSUInteger)identifieGenerator
{
//    return [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:1358344093]];
    return [[NSDate date] timeIntervalSince1970];
}

- (id)init
{
    if (self = [super init]) {
        self.title = @"";
        self.content = @"";
        self.identifie = 0;
    }
    
    return self;
}

- (void)finalizeContent
{
    NSString *sql = [NSString stringWithFormat:@"SELECT content FROM textTable WHERE id = %d", self.identifie];
    EGODatabaseResult *result = [[TEText textDatabase] executeQuery:sql];
    EGODatabaseRow *row = [result rowAtIndex:0];
    
    self.content = [row stringForColumn:@"content"];
}

- (NSDictionary *)jsonObject
{
    return @{@"id":[NSNumber numberWithUnsignedInteger:self.identifie], @"title":self.title, @"content":self.content};
}

@end
