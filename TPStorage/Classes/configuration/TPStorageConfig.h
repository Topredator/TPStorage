//
//  TPStorageConfig.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 配置项
@interface TPStorageConfig : NSObject
/// 数据库名称
@property (nonatomic, copy) NSString *dbName;
/// 数据库版本
@property (nonatomic, copy) NSString *dbVersion;
/// 一次 从数据库中回去数据的最大条数 默认100
@property (nonatomic, assign) NSInteger maxQueryNumber;
+ (instancetype)configName:(NSString *)name version:(NSString *)version;
@end

NS_ASSUME_NONNULL_END
