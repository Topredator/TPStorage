//
//  TPStorageOperator+Update.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageOperator+Update.h"

@implementation TPStorageOperator (Update)
- (void)updateDBWithSQL:(NSString *)sqlString callback:(void (^)(BOOL, NSString *))callback {
    if (!sqlString.length) {
        if (callback) callback(NO, @"请传入正确的sql语句");
        return;
    }
    __block BOOL isResult = NO;
    if ([self.mainDB open]) {
        [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            isResult = [db executeUpdate:sqlString];
            if (!isResult) {
                if (callback) callback(NO, @"更新失败");
                *rollback = YES;
            }
            if (callback) callback(YES, @"更新成功");
        }];
    }
}
@end
