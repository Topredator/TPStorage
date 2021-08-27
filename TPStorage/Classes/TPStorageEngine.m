//
//  TPStorageEngine.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageEngine.h"
#import "TPStorageOperator.h"
#import "TPStorageOperator+Insert.h"
#import "TPStorageOperator+Delete.h"
#import "TPStorageOperator+Query.h"
#import "TPStorageOperator+Update.h"
@interface TPStorageEngine () <TPStorageOperatorDelegate>
@property (nonatomic, strong) TPStorageConfig *storageConfig;
@property (nonatomic, strong) TPStorageOperator *operator;
@end


static TPStorageEngine *engine = nil;
@implementation TPStorageEngine

+ (instancetype)storageEngine {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [TPStorageEngine new];
    });
    return engine;
}
- (void)storageConfig:(TPStorageConfig *)config {
    if (!config) {
        self.storageConfig = [TPStorageConfig configName:@"com.TPStorage.app" version:@"0.1"];
    } else {
        self.storageConfig = config;
    }
    [self.operator createDBWithName:self.storageConfig.dbName version:self.storageConfig.dbVersion];
}
- (void)registerTableWithClassName:(NSString *)className {
    [self.operator addClassName:className];
}
- (BOOL)existColumn:(NSString *)columnName inTable:(NSString *)tableName {
    if (!columnName || !tableName) return NO;
    return [self.operator.mainDB columnExists:columnName inTableWithName:tableName];
}
#pragma mark ------------------------  存储操作  ---------------------------
/// 同步存储单个数据
- (BOOL)syncSaveModel:(__kindof TPStorageDBModel *)model {
    __block BOOL flag = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    [self.operator insertModel:model callback:^(BOOL result, NSString *msg) {
        flag = result;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return flag;
}
/// 异步存储单个数据
- (void)asyncSaveModel:(__kindof TPStorageDBModel *)model callback:(void (^)(BOOL result, NSString *msg))callback {
    [self.operator insertModel:model callback:callback];
}
/// 同步 批量存储
- (BOOL)syncSaveModels:(NSArray <TPStorageDBModel *>*)models {
    __block BOOL flag = NO;
       dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
       [self.operator insertModels:models callback:^(BOOL result, NSString *msg) {
           flag = result;
           dispatch_semaphore_signal(semaphore);
       }];
       dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
       return flag;
    return NO;
}
/// 异步 批量存储
- (void)asyncSaveModels:(NSArray<TPStorageDBModel *>*)models callback:(void (^)(BOOL result, NSString *msg))callback {
    [self.operator insertModels:models callback:callback];
}
#pragma mark ------------------------  delete 操作  ---------------------------
/// 同步删除单个数据
- (BOOL)syncDeleteModel:(__kindof TPStorageDBModel *)model {
    __block BOOL flag = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    [self.operator deleteModel:model callback:^(BOOL result, NSString *msg) {
        flag = result;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return flag;
}
/// 异步删除单个数据
- (void)asyncDeleteModel:(__kindof TPStorageDBModel *)model callback:(void (^)(BOOL result, NSString *msg))callback {
    [self.operator deleteModel:model callback:callback];
}
/// 同步批量删除
- (BOOL)syncDeleteModels:(NSArray <TPStorageDBModel *>*)models {
    __block BOOL flag = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    [self.operator deleteModels:models callback:^(BOOL result, NSString *msg) {
        flag = result;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return flag;
}
/// 异步批量删除
- (void)asyncDeleteModels:(NSArray <TPStorageDBModel *>*)models callback:(void (^)(BOOL result, NSString *msg))callback {
    [self.operator deleteModels:models callback:callback];
}
/// 同步 删除表中所有数据
- (BOOL)syncDeleteAllModels:(Class)modelClass {
    __block BOOL flag = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    [self.operator deleteAllModelsWithClass:modelClass callback:^(BOOL result, NSString *msg) {
        flag = result;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return flag;
}
/// 异步 删除表中所有数据
- (void)asyncDeleteAllModels:(Class)modelClass callback:(void (^)(BOOL result, NSString *msg))callback {
    [self.operator deleteAllModelsWithClass:modelClass callback:callback];
}

- (NSArray *)syncQueryModelsWithClass:(Class)modelClass SQL:(NSString *)sqlString {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    __block NSArray *result = @[];
    [self.operator queryModels:modelClass SQL:sqlString callback:^(NSArray * _Nonnull array, NSString * _Nonnull msg) {
        result = array;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}
- (__kindof TPStorageDBModel *)syncQueryModelWithClass:(Class)modelClass SQL:(NSString *)sqlString {
    NSArray *result = [self syncQueryModelsWithClass:modelClass SQL:sqlString];
    return result.count ? [result firstObject] : nil;
}
- (void)asyncQueryModelsWithClass:(Class)modelClass SQL:(NSString *)sqlString callback:(void (^)(NSArray *array, NSString *msg))callback {
    [self.operator queryModels:modelClass SQL:sqlString callback:callback];
}
- (NSArray *)syncQueryModelsWithClass:(Class)modelClass {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    __block NSArray *result = @[];
    [self.operator queryWithClass:modelClass maxNum:self.storageConfig.maxQueryNumber callback:^(NSArray * _Nonnull array, NSString * _Nonnull msg) {
        result = array;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}
- (void)asyncQueryModelsWithClass:(Class)modelClass callback:(void (^)(NSArray *array, NSString *msg))callback {
    [self.operator queryWithClass:modelClass maxNum:self.storageConfig.maxQueryNumber callback:callback];
}

- (BOOL)syncUpdateWithSQL:(NSString *)sqlString {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    __block BOOL isResult = NO;
    [self.operator updateDBWithSQL:sqlString callback:^(BOOL result, NSString *msg) {
        isResult = result;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return isResult;
}
- (void)asyncUpdateWithSQL:(NSString *)sql callback:(void (^)(BOOL result, NSString *msg))callback {
    [self.operator updateDBWithSQL:sql callback:callback];
}

#pragma mark ------------------------  TPStorageOperatorDelegate  ---------------------------
- (void)storageOperator:(TPStorageOperator *)storageOperator prepareTableMappingWithTableMapModel:(TPStorageTableMap *)mapModel {
    NSMutableArray *names = @[].mutableCopy;
    NSMutableArray *colArrs = @[].mutableCopy;
    /// 同步查询表数据
    [storageOperator syncQueryDB:^id(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type = 'table'"];
        while ([resultSet next]) {
            NSString *name = [resultSet stringForColumn:@"name"];
            if (![name isEqualToString:@"sqlite_sequence"]) {
                [names addObject:name];
            }
        }
        [resultSet close];
        for (NSString *name in names) {
            NSMutableArray *cols = [NSMutableArray array];
            FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)", name]];
            while ([resultSet next]) {
                [cols addObject:[resultSet stringForColumn:@"name"]];
            }
            [resultSet close];
            [colArrs addObject:cols];
        }
        return nil;
    }];
    
    for (int i = 0; i < names.count; i++) {
        NSString *key = names[i];
        NSArray *cols = colArrs[i];
        [mapModel setMap:key datas:cols];
    }
}
#pragma mark ------------------------  lazy method ---------------------------
- (TPStorageOperator *)operator {
    if (!_operator) {
        _operator = [TPStorageOperator new];
        _operator.delegate = self;
    }
    return _operator;
}
@end
