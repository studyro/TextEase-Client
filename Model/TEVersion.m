//
//  TEVersion.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-11.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEVersion.h"
#import "EGODatabase.h"
#import "NSString+QueryParams.h"

static EGODatabase *database = nil;

@implementation TEVersion

+ (EGODatabase *)versionDatabase;
{
    if (!database) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        NSString *databasePath = [docPath stringByAppendingPathComponent:@"version.db"];
        
        database = [[EGODatabase alloc] initWithPath:databasePath];
        
        NSString *tableSql = @"CREATE TABLE IF NOT EXISTS versionTable(fromVersion INTEGER, toVersion INTEGER PRIMARY KEY, changesVector TEXT, synced INTEGER DEFAULT 0)";
        
        [database executeUpdate:tableSql];
    }
    
    return database;
}

+ (NSUInteger)_maxVersionNumber
{
    NSString *maxVersionSql = @"SELECT max(toVersion) FROM versionTable";
    EGODatabaseResult *maxResult = [[TEVersion versionDatabase] executeQuery:maxVersionSql];
    if (![maxResult count]) {
        return 0;
    }
    EGODatabaseRow *maxRow = [maxResult rowAtIndex:0];
    NSUInteger maxVersion = [maxRow intForColumn:@"max(toVersion)"];
    
    return maxVersion;
}

+ (TEVersion *)newestVersion
{
    NSUInteger maxVersion = [TEVersion _maxVersionNumber];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM versionTable WHERE toVersion = %d", maxVersion];
    
    EGODatabaseResult *result = [[TEVersion versionDatabase] executeQuery:sql];
    TEVersion *version = nil;
    if ([result count]) {
        EGODatabaseRow *row = [result rowAtIndex:0];
        version = [[[TEVersion alloc] init] autorelease];
        version.fromVersion = [row intForColumn:@"fromVersion"];
        version.toVersion = [row intForColumn:@"toVersion"];
        version.changesVector = [row stringForColumn:@"changesVector"];
        version.syncedWithServer = [row intForColumn:@"synced"];
    }
    else {
        version = [[[TEVersion alloc] init] autorelease];
        version.fromVersion = 0;
        version.toVersion = 0;
        version.changesVector = @"";
        version.syncedWithServer = NO;
    }
    return version;
}

+ (TEVersion *)versionWithJsonObject:(NSDictionary *)jsonObject
{
    TEVersion *version = [[TEVersion alloc] init];
    
    version.fromVersion = [[jsonObject objectForKey:@"fromVersion"] integerValue];
    version.toVersion = [[jsonObject objectForKey:@"toVersion"] integerValue];
    version.changesVector = [jsonObject objectForKey:@"changesVector"];
    
    return [version autorelease];
}

+ (void)insertVersion:(TEVersion *)version
{
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO versionTable ('fromVersion', 'toVersion', 'changesVector', 'synced') VALUES (%u, %u, '%@', %d)", version.fromVersion, version.toVersion, version.changesVector, version.syncedWithServer];
    
    [[TEVersion versionDatabase] executeUpdate:sql];
}

+ (TEVersion *)createVersionOfVector:(NSDictionary *)vectorDic
{
    NSUInteger fromVersion = [TEVersion _maxVersionNumber];
    NSUInteger toVersion = fromVersion + 1;
    NSString *changesVector = [NSString queryStringWithParams:vectorDic];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO versionTable ('fromVersion', 'toVersion', 'changesVector') VALUES (%d, %d, '%@')", fromVersion, toVersion, changesVector];
    [[TEVersion versionDatabase] executeUpdate:sql];
    
    NSDictionary *jsonObj = @{@"fromVersion" : [NSNumber numberWithUnsignedInteger:fromVersion], @"toVersion" : [NSNumber numberWithUnsignedInteger:toVersion], @"changesVector" : changesVector};
    
    return [[self class] versionWithJsonObject:jsonObj];
}

+ (void)appendNewestVersionOfVector:(NSDictionary *)additionalVector
{
    TEVersion *version = [TEVersion newestVersion];
    version.changesVector = [[self class] _getCorrectlyAppendedVectorWithAdditionalVector:additionalVector andOriginVector:version.changesVector];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO versionTable ('fromVersion', 'toVersion', 'changesVector', 'synced') VALUES (%d, %d, '%@', %d)", version.fromVersion, version.toVersion, version.changesVector, version.syncedWithServer];
//    NSString *sql = [NSString stringWithFormat:@"UPDATE versionTable SET fromVersion=%ud, toVersion=%ud, changesVector=%@ WHERE toVersion=%ud", version.fromVersion, version.toVersion, version.changesVector, version.toVersion];
    [[TEVersion versionDatabase] executeUpdate:sql];
}

+ (NSString *)_getCorrectlyAppendedVectorWithAdditionalVector:(NSDictionary *)additionalVector andOriginVector:(NSString *)originVector
{
    NSMutableDictionary *originVectorDic = [[originVector paramsDictionary] mutableCopy];
    if (!originVectorDic) originVectorDic = [NSMutableDictionary dictionary];
    
    [additionalVector enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSString *commandType = [originVectorDic objectForKey:key];
        if (commandType) {
            if ([obj isEqualToString:@"delete"]) {
                // if this text was created in this version, the delete task makes like that this text was never created
                if ([originVectorDic objectForKey:key])
                    [originVectorDic removeObjectForKey:key];
                // otherwise, the text was created in former version, so, delete works fine.
                else
                    [originVectorDic setObject:obj forKey:key];
            }
        }
        else {
            [originVectorDic setObject:obj forKey:key];
        }
    }];
    
    return [NSString queryStringWithParams:originVectorDic];
}

- (NSDictionary *)jsonObject
{
    return @{@"fromVersion" : [NSNumber numberWithUnsignedInteger:self.fromVersion], @"toVersion" : [NSNumber numberWithUnsignedInteger:self.toVersion], @"changesVector" : self.changesVector};
}

@end
