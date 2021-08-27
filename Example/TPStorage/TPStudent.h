//
//  TPStudent.h
//  TPStorage_Example
//
//  Created by Topredator on 2021/8/27.
//  Copyright © 2021 周晓路. All rights reserved.
//

#import <TPStorage/TPStorage.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPStudent : TPStorageDBModel
@property (nonatomic, copy) NSString *studentId;
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@end

NS_ASSUME_NONNULL_END
