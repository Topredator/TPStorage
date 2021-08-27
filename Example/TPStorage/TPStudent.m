//
//  TPStudent.m
//  TPStorage_Example
//
//  Created by Topredator on 2021/8/27.
//  Copyright © 2021 周晓路. All rights reserved.
//

#import "TPStudent.h"

@implementation TPStudent
+ (void)load {
    [TPStorageEngine.storageEngine registerTableWithClassName:NSStringFromClass(self.class)];
}
- (NSArray<NSString *> *)combinedPrimaryKey {
    return @[@"schoolId", @"studentId"];
}
@end
