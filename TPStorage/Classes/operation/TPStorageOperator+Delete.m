//
//  TPStorageOperator+Delete.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator+Delete.h"

@implementation TPStorageOperator (Delete)
- (void)deleteModel:(__kindof TPStorageDBModel *)model callback:(void (^)(BOOL result, NSString *msg))callback {
    if (![self.mainDB open]) return;
    __weak typeof(self) weakSelf = self;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL flag = [weakSelf deleteTableDataWithDB:db model:model];
        if (callback) callback(flag, flag ? @"删除成功" : @"删除失败");
    }];
}
- (void)deleteModels:(NSArray *)models callback:(void (^)(BOOL result, NSString *msg))callback {
    if (![self.mainDB open]) return;
    __block BOOL flag = NO;
    __weak typeof(self) weakSelf = self;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            flag = [weakSelf deleteTableDataWithDB:db model:obj];
            if (!flag) *stop = YES;
        }];
        if (!flag) {
            if (callback) callback(NO, @"删除失败");
            *rollback = YES;
        }
        if (callback) callback(YES, @"删除成功");
    }];
}
- (void)deleteAllModelsWithClass:(Class)modelClass callback:(void (^)(BOOL result, NSString *msg))callback {
    if (![self.mainDB open]) return;
    __weak typeof(self) weakSelf = self;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL flag = [weakSelf deleteAllTableData:db modelClass:modelClass];
        if (callback) callback(flag, flag ? @"删除成功" : @"删除失败");
    }];
}
- (BOOL)deleteAllTableData:(FMDatabase *)db modelClass:(Class)modelClass {
    if ([db open]) {
        if ([self isExistTable:db modelClass:modelClass]) {
            BOOL result = [db executeUpdate:[self generateDeleteAllTableDataWithClass:modelClass]];
            return result;
        }
        return YES;
    }
    return NO;
}
/// 删除所有表数据
- (NSString *)generateDeleteAllTableDataWithClass:(Class)modelClass {
    return [NSString stringWithFormat:@"DELETE FROM %@;", modelClass];
}
- (BOOL)deleteTableDataWithDB:(FMDatabase *)db model:(TPStorageDBModel *)model {
    if (![model isKindOfClass:[TPStorageDBModel class]]) return NO;
    
    if ([db open]) {
        if ([self isExistTable:db modelClass:[model class]]) {
            return [db executeUpdate:[self generateDeleteSQLWithModel:model]];
        }
        return YES;
    }
    return NO;
}
/// 通过model 生成删除sql 语句
- (NSString *)generateDeleteSQLWithModel:(TPStorageDBModel *)model {
    NSString *primaryKey = @"dbColumnId";
    if ([[model class] conformsToProtocol:@protocol(TPStoragePrimaryKey)]) {
        if ([model respondsToSelector:@selector(singlePrimaryKey)]) {
            primaryKey = [model singlePrimaryKey];
            return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@';", [model class], primaryKey, [model valueForKey:primaryKey]];
        }
        if ([model respondsToSelector:@selector(combinedPrimaryKey)]) {
            NSArray *primaryKeys = [model combinedPrimaryKey];
            // 拼接sql语句
            NSMutableString *deleteSQL = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE ", [model class]];
            for (NSString *key in primaryKeys) {
                NSString *str = [NSString stringWithFormat:@"%@ = '%@' and ", key, [model valueForKey:key]];
                [deleteSQL appendString:str];
            }
            [deleteSQL deleteCharactersInRange:NSMakeRange(deleteSQL.length - 5, 5)];
            [deleteSQL appendString:@";"];
            return deleteSQL;
        }
    }
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@';", model.class, primaryKey, [model valueForKey:primaryKey]];
}
@end
