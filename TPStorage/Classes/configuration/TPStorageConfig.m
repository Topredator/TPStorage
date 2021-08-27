//
//  TPStorageConfig.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageConfig.h"

@implementation TPStorageConfig
+ (instancetype)configName:(NSString *)name version:(NSString *)version {
    TPStorageConfig *config = [TPStorageConfig new];
    config.dbName = name;
    config.dbVersion = version;
    return config;
}
- (NSInteger)maxQueryNumber {
    if (_maxQueryNumber == 0) {
        _maxQueryNumber = 100;
    }
    return _maxQueryNumber;
}
@end
