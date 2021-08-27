//
//  TPStorageOperator+Update.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator.h"

NS_ASSUME_NONNULL_BEGIN

/// 更新数据 扩展
@interface TPStorageOperator (Update)
/// 更新
/// @param sqlString sql语句
/// @param callback 回调
- (void)updateDBWithSQL:(NSString *)sqlString callback:(void (^)(BOOL result, NSString *msg))callback;
@end

NS_ASSUME_NONNULL_END
