//
//  TPStorageEngine.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import <Foundation/Foundation.h>
#import "TPStorageConfig.h"
#import "TPStorageDBModel.h"
NS_ASSUME_NONNULL_BEGIN

/// 存储引擎 功能调用类
@interface TPStorageEngine : NSObject
/// 单例初始化
+ (instancetype)storageEngine;
/// 设置配置项
- (void)storageConfig:(TPStorageConfig *)config;

/// 通过类名 创建表
/// @param className 注册的表名称(类名即 表名)
- (void)registerTableWithClassName:(NSString *)className;
/// xxx表中是否存在xxx字段
/// @param columnName 字段名
/// @param tableName 表名
- (BOOL)existColumn:(NSString *)columnName inTable:(NSString *)tableName;

#pragma mark ------------------------  存储操作  ---------------------------
/// 同步存储单个数据
- (BOOL)syncSaveModel:(__kindof TPStorageDBModel *)model;
/// 异步存储单个数据
- (void)asyncSaveModel:(__kindof TPStorageDBModel *)model callback:(void (^)(BOOL result, NSString *msg))callback;
/// 同步 批量存储
- (BOOL)syncSaveModels:(NSArray <TPStorageDBModel *>*)models;
/// 异步 批量存储
- (void)asyncSaveModels:(NSArray<TPStorageDBModel *>*)models callback:(void (^)(BOOL result, NSString *msg))callback;
#pragma mark ------------------------  删除操作  ---------------------------
/// 同步删除单个数据
- (BOOL)syncDeleteModel:(__kindof TPStorageDBModel *)model;
/// 异步删除单个数据
- (void)asyncDeleteModel:(__kindof TPStorageDBModel *)model callback:(void (^)(BOOL result, NSString *msg))callback;
/// 同步批量删除
- (BOOL)syncDeleteModels:(NSArray <TPStorageDBModel *>*)models;
/// 异步批量删除
- (void)asyncDeleteModels:(NSArray <TPStorageDBModel *>*)models callback:(void (^)(BOOL result, NSString *msg))callback;
/// 同步 删除表中所有数据
- (BOOL)syncDeleteAllModels:(Class)modelClass;
/// 异步 删除表中所有数据
- (void)asyncDeleteAllModels:(Class)modelClass callback:(void (^)(BOOL result, NSString *msg))callback;
#pragma mark ------------------------  查询操作  ---------------------------
/// 通过sql语句 同步查询
- (NSArray *)syncQueryModelsWithClass:(Class)modelClass SQL:(NSString *)sqlString;
/// 查询单个数据
- (__kindof TPStorageDBModel *)syncQueryModelWithClass:(Class)modelClass SQL:(NSString *)sqlString;
/// 通过sql语句 异步查询
- (void)asyncQueryModelsWithClass:(Class)modelClass SQL:(NSString *)sqlString callback:(void (^)(NSArray *array, NSString *msg))callback;
/// 通过类型 同步查询
- (NSArray *)syncQueryModelsWithClass:(Class)modelClass;
/// 通过类型 异步查询
- (void)asyncQueryModelsWithClass:(Class)modelClass callback:(void (^)(NSArray *array, NSString *msg))callback;
#pragma mark ------------------------  更新操作  ---------------------------
/// 同步更新
- (BOOL)syncUpdateWithSQL:(NSString *)sqlString;
/// 异步更新
- (void)asyncUpdateWithSQL:(NSString *)sql callback:(void (^)(BOOL result, NSString *msg))callback;

@end

NS_ASSUME_NONNULL_END
