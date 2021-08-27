//
//  TPSchool.m
//  TPStorage_Example
//
//  Created by Topredator on 2021/8/27.
//  Copyright © 2021 周晓路. All rights reserved.
//

#import "TPSchool.h"

@implementation TPSchool
+ (void)load {
    [TPStorageEngine.storageEngine registerTableWithClassName:NSStringFromClass(self.class)];
}

- (NSString *)singlePrimaryKey {
    return @"schoolId";
}
@end
