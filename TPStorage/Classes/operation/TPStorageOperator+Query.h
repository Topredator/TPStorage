//
//  TPStorageOperator+Query.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator.h"

NS_ASSUME_NONNULL_BEGIN

/// 查询数据 扩展
@interface TPStorageOperator (Query)
/**
 同步查询数据
 @param block 查询操作
 @return 查询结果
 */
- (id)syncQueryDB:(id (^)(FMDatabase *db))block;

/// 通过类对应的数据表查询
/// @param modelClass 表对应的类
/// @param maxNum 最大数量
/// @param callback 回调
- (void)queryWithClass:(Class)modelClass maxNum:(NSInteger)maxNum callback:(void (^)(NSArray *array, NSString *msg))callback;

/// 通过sql语句查询
/// @param modelClass 表 对应的类
/// @param sqlString sql语句
/// @param callback 回调
- (void)queryModels:(Class)modelClass SQL:(NSString *)sqlString callback:(void (^)(NSArray *array, NSString *msg))callback;
@end

NS_ASSUME_NONNULL_END
