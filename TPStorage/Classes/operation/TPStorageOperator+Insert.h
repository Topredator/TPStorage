//
//  TPStorageOperator+Insert.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator.h"

NS_ASSUME_NONNULL_BEGIN

/// 添加数据 扩展
@interface TPStorageOperator (Insert)
/// 插入单个数据
/// @param model 需要插入的数据模型
/// @param callback 回调
- (void)insertModel:(TPStorageDBModel<TPStoragePrimaryKey> *)model callback:(void (^)(BOOL result, NSString *msg))callback;

/// 批量插入
/// @param models 批量数据
/// @param callback 回调
- (void)insertModels:(NSArray <TPStorageDBModel<TPStoragePrimaryKey> *>*)models callback:(void (^)(BOOL result, NSString *msg))callback;
@end

NS_ASSUME_NONNULL_END
