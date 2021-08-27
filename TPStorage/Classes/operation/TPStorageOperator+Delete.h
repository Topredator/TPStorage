//
//  TPStorageOperator+Delete.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator.h"

NS_ASSUME_NONNULL_BEGIN

/// 删除数据 扩展
@interface TPStorageOperator (Delete)
/// 删除单个数据
/// @param model 要删除的数据模型
/// @param callback 回调
- (void)deleteModel:(__kindof TPStorageDBModel *)model callback:(void (^)(BOOL result, NSString *msg))callback;

/// 批量删除数据
/// @param models 批量模型
/// @param callback 回调
- (void)deleteModels:(NSArray *)models callback:(void (^)(BOOL result, NSString *msg))callback;
/// 删除表类 对应的所有数据
/// @param modelClass 表对应的类型
/// @param callback 回调
- (void)deleteAllModelsWithClass:(Class)modelClass callback:(void (^)(BOOL result, NSString *msg))callback;
@end

NS_ASSUME_NONNULL_END
