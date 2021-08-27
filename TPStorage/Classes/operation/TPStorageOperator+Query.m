//
//  TPStorageOperator+Query.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator+Query.h"
#import <Asterism/Asterism.h>
@implementation TPStorageOperator (Query)
- (void)queryWithClass:(Class)modelClass maxNum:(NSInteger)maxNum callback:(void (^)(NSArray *array, NSString *msg))callback {
    if ([self.mainDB open]) {
        __weak typeof(self) weakSelf = self;
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL result = [weakSelf isExistTable:db modelClass:modelClass];
            if (!result) {
                if (callback) callback(@[], [NSString stringWithFormat:@"%@表不存在", NSStringFromClass(modelClass)]);
                return;
            }
            NSString *sqlCode = [weakSelf generateQuerySQLWithModelClass:modelClass maxNum:maxNum];
            FMResultSet *rs = [db executeQuery:sqlCode];
            NSMutableArray *resultList = @[].mutableCopy;
            while ([rs next]) {
                TPStorageDBModel *model = [weakSelf fetchDBModel:modelClass resultSet:rs];
                [resultList addObject:model];
            }
            [rs close];
            if (callback) callback(resultList.copy, @"查询成功");
        }];
    }
}
- (void)queryModels:(Class)modelClass SQL:(NSString *)sqlString callback:(void (^)(NSArray *array, NSString *msg))callback {
    if (![self.mainDB open]) return;
    __weak typeof(self) weakSelf = self;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (!sqlString.length) {
            if (callback) callback(@[], @"请传入正确的sql语句");
            return;
        }
        NSMutableArray *resultList = @[].mutableCopy;
        FMResultSet *resultSet = [db executeQuery:sqlString];
        while ([resultSet next]) {
            TPStorageDBModel *model = [weakSelf fetchDBModel:modelClass resultSet:resultSet];
            [resultList addObject:model];
        }
        [resultSet close];
        if (callback) callback(resultList.copy, @"查询成功");
    }];
}
- (TPStorageDBModel *)fetchDBModel:(Class)modelClass resultSet:(FMResultSet *)resultSet {
    TPStorageDBModel *model = [(TPStorageDBModel *)[[modelClass class] alloc] init];
    NSArray *propertyNames = [model propertyNames];
    NSArray *typeList = [model propertyTypes];
    ASTEach(propertyNames, ^(NSString *obj, NSUInteger idx) {
        id value = [resultSet objectForColumn:obj];
        if (value) {
            if ([value isKindOfClass:[NSString class]]) {
                id result = [self stringToData:value];
                if ([result isKindOfClass:[NSDictionary class]] ||
                    [result isKindOfClass:[NSMutableDictionary class]] ||
                    [result isKindOfClass:[NSArray class]] ||
                    [result isKindOfClass:[NSMutableArray class]]) {
                    [model setValue:result forKey:obj];
                } else {
                    [model setValue:value forKey:obj];
                }
            } else if ([value isKindOfClass:[NSNumber class]]) {
                id result = [value stringValue];
                [model setValue:result forKey:obj];
            } else {
                NSString *type = [typeList objectAtIndex:idx];
                if ([type containsString:@"NSString"]) {
                    [model setValue:@"" forKey:obj];
                }else if ([type containsString:@"NSDictionary"]) {
                    [model setValue:[NSDictionary dictionary] forKey:obj];
                }else if ([type containsString:@"NSArray"]) {
                    [model setValue:[NSArray array] forKey:obj];
                }else {
                    [model setValue:value forKey:obj];
                }
            }
        }
    });
    return model;
}

- (id)syncQueryDB:(id (^)(FMDatabase *db))block {
    __block id result = nil;
    void (^queryBlock) (FMDatabase *db) = ^ (FMDatabase *db) {
        result = block(db);
    };
    if ([NSThread.currentThread isMainThread]) {
        return block(self.mainDB);
    } else {
        [self.dbQueue inDatabase:queryBlock];
        return result;
    }
}
/// 通过 模型类 生成查询sql语句
- (NSString *)generateQuerySQLWithModelClass:(Class)modelClass maxNum:(NSInteger)maxNum {
    return [NSString stringWithFormat:@"SELECT * FROM %@ desc limit %ld;", NSStringFromClass(modelClass), maxNum];
}
@end
