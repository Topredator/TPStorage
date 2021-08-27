//
//  TPSchool.h
//  TPStorage_Example
//
//  Created by Topredator on 2021/8/27.
//  Copyright © 2021 周晓路. All rights reserved.
//

#import <TPStorage/TPStorage.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPSchool : TPStorageDBModel
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, copy) NSString *schoolName;
@property (nonatomic, copy) NSString *address;
/// 是否开学
@property (nonatomic, assign) BOOL termBegins;
@end

NS_ASSUME_NONNULL_END
