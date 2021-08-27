//
//  TPStorageTableMap.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 数据表映射类  用于存储数据表信息，及映射信息
@interface TPStorageTableMap : NSObject
/// 存储 表名：表数据
@property (nonatomic, strong, readonly) NSMutableDictionary *tablesMap;
/// 存储 {表名："字段名, 字段名, ...."}
@property (nonatomic, strong, readonly) NSMutableDictionary *tablesInsertSQLMap;
/// 存储 {表名：":字段名, :字段名, ...."}
@property (nonatomic, strong, readonly) NSMutableDictionary *tablesInsertDataMap;
/// 单例初始化
+ (instancetype)tableMap;
/// 映射存储 表数据
- (void)setMap:(NSString *)tableName datas:(NSArray *)datas;
@end

NS_ASSUME_NONNULL_END
