//
//  TPStorageDBHandler.h
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import <Foundation/Foundation.h>
#import "TPStorageTableMap.h"
#import <fmdb/FMDB.h>
#import "TPStorageDBModel.h"
NS_ASSUME_NONNULL_BEGIN

@class TPStorageOperator;
@protocol TPStorageOperatorDelegate <NSObject>
- (void)storageOperator:(TPStorageOperator *)storageOperator
    prepareTableMappingWithTableMapModel:(TPStorageTableMap *)mapModel;
@end




/// 数据库 操作类
@interface TPStorageOperator : NSObject
@property (nonatomic, weak) id <TPStorageOperatorDelegate> delegate;
/// 数据库对象
@property (nonatomic, strong, readwrite) FMDatabase *mainDB;
/// 串行队列，用于处理事务
@property (nonatomic, strong, readwrite) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong, readwrite) dispatch_queue_t dataBaseQueue;
@property (nonatomic, strong, readwrite) NSMutableOrderedSet *tableNames;


/**
 添加类名用于表的创建
 */
- (void)addClassName:(NSString *)className;
/// 通过类 创建表
- (BOOL)createTable:(FMDatabase *)db modelClass:(Class)modelClass;
/// 判断表 是否存在
- (BOOL)isExistTable:(FMDatabase *)db modelClass:(Class)modelClass;

///将json data转换成字符串
- (NSString *)dataToString:(id)data;
///将字符串转换成json data
- (id)stringToData:(NSString *)str;

/**
 通过数据库名称 创建数据库

 @param dbName 数据库名称
 @param version 数据库版本，为更新使用
 */
- (void)createDBWithName:(NSString *)dbName version:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
