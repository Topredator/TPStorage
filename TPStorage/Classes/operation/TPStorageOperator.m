//
//  TPStorageDBHandler.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator.h"
#import <Asterism/Asterism.h>


static NSString *kTPStorageDBDefault = @"com.tp.storage.userDefault";

@implementation TPStorageOperator
- (void)createDBWithName:(NSString *)dbName version:(NSString *)version {
    NSString *sqlPath = [self databasePath:dbName];
    self.mainDB = [FMDatabase databaseWithPath:sqlPath];
    if ([self.mainDB open]) {
        // 使用单例 存储表数据
        [self.delegate storageOperator:self prepareTableMappingWithTableMapModel:TPStorageTableMap.tableMap];
        /// 开始事务
        [self.mainDB beginTransaction];
        /// 判断数据库版本是否一致，不一致删除源数据库重建 (用于数据库版本更新)
            /// 获取所有数据
        NSMutableDictionary *mdic = [self tryToDropTableWithVersion:version];
            /// 重新创建数据库并把所有数据存储 (通过类名 创建表)
        [self createTables];
        NSDictionary *SQLMap = [TPStorageTableMap.tableMap tablesInsertSQLMap].copy;
        NSDictionary *dataMap = [TPStorageTableMap.tableMap tablesInsertDataMap].copy;
        
        [self.delegate storageOperator:self prepareTableMappingWithTableMapModel:TPStorageTableMap.tableMap];
        
        NSDictionary *SQLMap1 = [TPStorageTableMap.tableMap tablesInsertSQLMap].copy;
        NSDictionary *dataMap1 = [TPStorageTableMap.tableMap tablesInsertDataMap].copy;
        
        ASTEach(mdic, ^(NSString *tableName, id obj) {
            /// 前后两次 对比插入
            NSArray *columns1 = [SQLMap[tableName] componentsSeparatedByString:@","];
            NSArray *dataNames1 = [dataMap[tableName] componentsSeparatedByString:@","];
            NSArray *columns2 = [SQLMap1[tableName] componentsSeparatedByString:@","];
            NSArray *dataNames2 = [dataMap1[tableName] componentsSeparatedByString:@","];
            
            NSMutableArray *columns = [NSMutableArray array];
            NSString *columnsStr = @"";
            for (NSString *str1 in columns1) {
                for (NSString *str2 in columns2) {
                    if ([str1 isEqualToString:str2]) {
                        [columns addObject:str1];
                        columnsStr = [NSString stringWithFormat:@"%@,%@", columnsStr, str1];
                        break;
                    }
                }
            }
            columnsStr = [columnsStr substringFromIndex:1];
            NSString *dicnamesStr = @"";
            for (NSString *str1 in dataNames1) {
                for (NSString *str2 in dataNames2) {
                    if ([str1 isEqualToString:str2]) {
                        dicnamesStr = [NSString stringWithFormat:@"%@,%@", dicnamesStr,str1];
                        break;
                    }
                }
            }
            dicnamesStr = [dicnamesStr substringFromIndex:1];
            NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@(%@) VALUES(%@)",tableName,columnsStr,dicnamesStr];
            for (NSMutableDictionary *dic in obj) {
                NSMutableDictionary *columnsDic = [NSMutableDictionary dictionary];
                [dic enumerateKeysAndObjectsUsingBlock:^(id str1, id obj, BOOL *stop) {
                    for (NSString *str2 in columns) {
                        if ([str1 isEqualToString:str2]) {
                            [columnsDic setObject:obj forKey:str1];
                            break;
                        }
                    }
                }];
                [self.mainDB executeUpdate:sql withParameterDictionary:columnsDic];
            }
        });
        [self.mainDB commit];
    } else {
        [self.delegate storageOperator:self prepareTableMappingWithTableMapModel:TPStorageTableMap.tableMap];
    }
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    self.dataBaseQueue = dispatch_queue_create("com.xt.storage.dbqueue", 0);
}
- (NSString *)dataToString:(id)data {
    NSError *parseError = nil;
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDic = data;
        NSMutableDictionary *complteDic = [NSMutableDictionary dictionary];
        if (dataDic.allKeys.count > 0) {
            for (NSString *key in dataDic.allKeys) {
                if (key && [key isKindOfClass:[NSString class]] && ![key isEqualToString:@""]) {
                    if (dataDic[key]) {
                        [complteDic setObject:dataDic[key] forKey:key];
                    }
                }
            }
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:complteDic options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return str;
    }else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return str;
    }
}
///将字符串转换成json data
- (id)stringToData:(NSString *)str {
    if (!str) return nil;
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id data = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingMutableContainers
                                                error:&err];
    if(err) return nil;
    return data;
}

#pragma mark ------------------------  private method  ---------------------------
- (NSString *)databaseDirPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *directory = [documentDirectory stringByAppendingPathComponent:@"TPStorage"];
    NSFileManager *manager = NSFileManager.defaultManager;
    if (![manager fileExistsAtPath:directory]) {
        [manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return directory;
}
- (NSString *)databasePath:(NSString *)dbName {
    return [[self databaseDirPath] stringByAppendingPathComponent:dbName];
}
/// 通过版本 drop table 然后 从新创建
- (NSMutableDictionary *)tryToDropTableWithVersion:(NSString *)version {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    /// 获取存储的版本
    id dbVersion = [ud valueForKey:kTPStorageDBDefault];
    if (!dbVersion) {
        [ud setValue:version forKey:kTPStorageDBDefault];
    } else if (![version isEqualToString:dbVersion]) {
        [ud setValue:version forKey:kTPStorageDBDefault];
        
        // 数据库语句
        NSString *sqlFormat = @"DROP TABLE IF EXISTS %@";
        NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
        
        for (NSString *tableName in TPStorageTableMap.tableMap.tablesMap.allKeys) {
            NSMutableArray *marr = @[].mutableCopy;
            FMResultSet *rs = [self.mainDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", tableName]];
            while ([rs next]) {
                [marr addObject:[rs resultDictionary]];
            }
            [rs close];
            // 存储 表数据
            [mdic setObject:marr forKey:tableName];
            // 删除表
            [self.mainDB executeUpdate:[NSString stringWithFormat:sqlFormat, tableName]];
        }
        return mdic;
    }
    return nil;
}
- (void)createTables {
    if (!self.tableNames.count) return;
    ASTEach(self.tableNames, ^(NSString *obj, NSUInteger idx) {
        [self createTable:self.mainDB modelClass:NSClassFromString(obj)];
    });
}

#pragma mark ------------------------  table operation  ---------------------------
/// 通过类 创建表
- (BOOL)createTable:(FMDatabase *)db modelClass:(Class)modelClass {
    if ([db open]) {
        if ([self isExistTable:db modelClass:modelClass]) {
            return YES;
        } else {
            return [db executeUpdate:[self generateCreateTableSQLWithClass:modelClass]];
        }
    }
    return NO;
}
// 通过类 判断表是否存在
- (BOOL)isExistTable:(FMDatabase *)db modelClass:(Class)modelClass {
    if ([db open]) {
        return [db tableExists:NSStringFromClass(modelClass)];
    }
    return NO;
}
/// 通过类  创建生成表的sql语句
- (NSString *)generateCreateTableSQLWithClass:(Class)modelClass {
    NSMutableString *sqlCode = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", modelClass];
    id model = [modelClass new];
    NSArray *propertyNames = [(TPStorageDBModel *)model propertyNames];
    ASTEach(propertyNames, ^(NSString *obj, NSUInteger idx) {
        [sqlCode appendFormat:@" %@,", obj];
    });
    // 单个主键设置 与 联合主键 是互斥的，只能设置一个，且单个主键优先级高
    if ([modelClass conformsToProtocol:@protocol(TPStoragePrimaryKey)]) {
        if ([model respondsToSelector:@selector(singlePrimaryKey)]) {
            NSString *primaryKey = [model singlePrimaryKey];
            if (primaryKey.length) {
                [sqlCode appendFormat:@" PRIMARY KEY(%@)", primaryKey];
            }
        }
        if (![sqlCode containsString:@"PRIMARY KEY"]) {
            if ([model respondsToSelector:@selector(combinedPrimaryKey)]) {
                NSArray *primaryKeys = [model combinedPrimaryKey];
                if (primaryKeys.count) {
                    NSString *str = [primaryKeys componentsJoinedByString:@","];
                    [sqlCode appendFormat:@" PRIMARY KEY(%@)", str];
                }
            }
        }
        if (![sqlCode containsString:@"PRIMARY KEY"]) {
            [sqlCode appendString:@"PRIMARY KEY(dbColumnId)"];
        }
    }
    [sqlCode appendString:@")"];
    NSLog(@"sqlCode = %@", sqlCode);
    return sqlCode;
}
- (void)addClassName:(NSString *)className {
    [self.tableNames addObject:className];
}

#pragma mark ------------------------  lazy method  ---------------------------
- (NSMutableOrderedSet *)tableNames {
    if (!_tableNames) {
        _tableNames = [NSMutableOrderedSet new];
    }
    return _tableNames;
}

@end
