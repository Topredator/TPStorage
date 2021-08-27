//
//  TPStorageOperator+Insert.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator+Insert.h"
#import <Asterism/Asterism.h>
@implementation TPStorageOperator (Insert)
- (void)insertModel:(TPStorageDBModel<TPStoragePrimaryKey> *)model callback:(void (^)(BOOL result, NSString *msg))callback {
    if (![self.mainDB open]) return;
    __block BOOL flag = YES;
    __weak typeof(self) weakSelf = self;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (!model || ![model isKindOfClass:[TPStorageDBModel class]]) {
            flag = NO;
        } else {
            flag = [weakSelf insertModeWithDB:db model:model];
        }
        if (callback) callback(flag, flag ? @"插入成功" : @"插入失败");
    }];
}

- (void)insertModels:(NSArray <TPStorageDBModel<TPStoragePrimaryKey> *>*)models callback:(void (^)(BOOL result, NSString *msg))callback {
    if (!models || !models.count) return;
    if (![self.mainDB open]) return;
    __weak typeof(self) weakSelf = self;
    __block BOOL flag = YES;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (TPStorageDBModel *model in models) {
            if (![model isKindOfClass:[TPStorageDBModel class]]) {
                flag = NO;
                break;
            }
            flag = [weakSelf insertModeWithDB:db model:model];
            if (!flag) break;
        }
        if (!flag) {
            if (callback) callback(NO, @"插入失败");
            *rollback = YES;
        }
        if (callback) callback(YES, @"插入成功");
    }];
}
- (BOOL)insertModelWithSQL:(NSString *)sqlString {
    if ([self.mainDB open]) {
        BOOL result = [self.mainDB executeUpdate:sqlString];
        return result;
    }
    return NO;
}
- (BOOL)insertModeWithDB:(FMDatabase *)db model:(TPStorageDBModel *)model {
    if (![model isKindOfClass:[TPStorageDBModel class]]) return NO;
    if ([db open]) {
        if ([self isExistTable:db modelClass:[model class]]) { // 表已存在
            BOOL result = [db executeUpdate:[self generateInsertSQLWithModel:model]];
            return result;
        } else {
            // 创建表
            BOOL isCreate = [self createTable:db modelClass:[model class]];
            if (isCreate) { // 插入
                return [db executeUpdate:[self generateInsertSQLWithModel:model]];
            }
            return NO;
        }
    }
    return NO;
}
// 通过model 生成插入sql 语句
- (NSString *)generateInsertSQLWithModel:(TPStorageDBModel *)model {
    NSMutableString *sqlCode = [NSMutableString stringWithFormat:@"REPLACE INTO %@ (", [model class]];
    NSArray *propertyNames = [model propertyNames];
    ASTEach(propertyNames, ^(NSString *obj, NSUInteger idx) {
        if (idx == 0) {
            [sqlCode appendFormat:@"%@", obj];
        } else {
            [sqlCode appendFormat:@", %@", obj];
        }
    });
    [sqlCode appendString:@") VALUES ("];
    
    ASTEach(propertyNames, ^(NSString *obj, NSUInteger idx) {
        id value = [model valueForKey:obj];
        if (value == [NSNull null]) value = @"";
        // 判断value类型
        if ([value isKindOfClass:[NSDictionary class]] ||
            [value isKindOfClass:[NSMutableDictionary class]] ||
            [value isKindOfClass:[NSArray class]] ||
            [value isKindOfClass:[NSMutableArray class]]) {
            // 对象转字符串
            value = [self dataToString:value];
        }
        if (idx == 0) {
            [sqlCode appendFormat:@"%@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value ? [value stringByReplacingOccurrencesOfString:@"\n" withString:@""] : @""] : value ? value : @"''"];
        } else {
            [sqlCode appendFormat:@", %@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value ? [value stringByReplacingOccurrencesOfString:@"\n" withString:@""] : @""] : value ? value : @"''"];
        }
    });
    [sqlCode appendString:@");"];
    return sqlCode;
}
@end
