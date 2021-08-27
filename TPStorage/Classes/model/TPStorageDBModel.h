//
//  TPStorageDBModel.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 设置主键协议
 1、提供两种设置方法
 2、单个主键设置 与 联合主键 是互斥的，只能设置一个，且单个主键优先级高
 */
@protocol TPStoragePrimaryKey <NSObject>
@optional
// 单一主键
- (NSString *)singlePrimaryKey;
/// 联合主键
- (NSArray <NSString *>*)combinedPrimaryKey;
@end

@protocol TPStorageIgnorePropertyKey <NSObject>
@optional
/// 需要忽视的属性 前缀(如：name -> ig_name)
+ (NSString *)ignoreKeyPrefixName;
@end


/// 数据库基础 存储模型 (使用时 需继承)
@interface TPStorageDBModel : NSObject <TPStoragePrimaryKey, TPStorageIgnorePropertyKey>
/// 创建model时自动生成，标识每一个数据(主键)
@property (nonatomic, copy) NSString *dbColumnId;
/// 所有属性 类型
- (NSArray *)propertyTypes;
/// 所有属性 名称
- (NSArray *)propertyNames;
@end

NS_ASSUME_NONNULL_END
