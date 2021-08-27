//
//  TPStorageDBModel.m
//  TPStorage
//
//  Created by Topredator on 2021/8/27.
//

#import "TPStorageDBModel.h"
#import <objc/runtime.h>

@implementation TPStorageDBModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dbColumnId = [self getRandomId];
    }
    return self;
}
#pragma mark ------------------------  runtime  ---------------------------
- (NSArray *)propertyTypes {
    NSString *propertyPrefix = nil;
    /// 有前缀的属性
    if ([self.class respondsToSelector:@selector(ignoreKeyPrefixName)]) {
        propertyPrefix = [self.class ignoreKeyPrefixName];
    }
    unsigned int count;
    Ivar * propertyList = class_copyIvarList([self class], &count);
    NSMutableArray *nameList = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        Ivar ivar = propertyList[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if (propertyPrefix && [name hasPrefix:[NSString stringWithFormat:@"_%@", propertyPrefix]]) continue;
        NSString * key = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)] ;
        [nameList addObject:key];
    }
    free(propertyList);
    // 获取子类属性类型
    Class checkClass = class_getSuperclass([self class]);
    while ([checkClass isSubclassOfClass:[TPStorageDBModel class]]) {
        NSString *superPropertyPrefix = nil;
        if ([checkClass respondsToSelector:@selector(ignoreKeyPrefixName)]) {
            superPropertyPrefix = [checkClass ignoreKeyPrefixName];
        }
        unsigned int superCount;
        Ivar * superPropertyList = class_copyIvarList(checkClass, &superCount);
        for (int i = 0; i < superCount; i ++) {
            Ivar ivar = superPropertyList[i];
            NSString * key = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)] ;
            NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (superPropertyPrefix && [name hasPrefix:[NSString stringWithFormat:@"_%@", superPropertyPrefix]]) continue;
            [nameList addObject:key];
        }
        free(superPropertyList);
        checkClass = class_getSuperclass([checkClass class]);
    }
    return nameList;
}
- (NSArray *)propertyNames {
    NSString *propertyPrefix = nil;
    if ([self.class respondsToSelector:@selector(ignoreKeyPrefixName)]) {
        propertyPrefix = [self.class ignoreKeyPrefixName];
    }
    unsigned int count;
    Ivar * propertyList = class_copyIvarList([self class], &count);
    NSMutableArray *nameList = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        Ivar ivar = propertyList[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
        if (propertyPrefix && [key hasPrefix:[NSString stringWithFormat:@"_%@", propertyPrefix]]) continue;
        //去除第一个"_"字符
        if([[key substringToIndex:1] isEqualToString:@"_"]){
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        [nameList addObject:key];
    }
    free(propertyList);
    // 获取子类属性名称
    Class checkClass = class_getSuperclass([self class]);
    while ([checkClass isSubclassOfClass:[TPStorageDBModel class]]) {
        NSString *superPropertyPrefix = nil;
        if ([checkClass respondsToSelector:@selector(ignoreKeyPrefixName)]) {
            superPropertyPrefix = [checkClass ignoreKeyPrefixName];
        }
        unsigned int superCount;
        Ivar * superPropertyList = class_copyIvarList(checkClass, &superCount);
        for (int i = 0; i < superCount; i ++) {
            Ivar ivar = superPropertyList[i];
            NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (superPropertyPrefix && [key hasPrefix:[NSString stringWithFormat:@"_%@", superPropertyPrefix]]) continue;
            //去除第一个"_"字符
            if([[key substringToIndex:1] isEqualToString:@"_"]){
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            [nameList addObject:key];
        }
        free(superPropertyList);
        checkClass = class_getSuperclass([checkClass class]);
    }
    return nameList;
}
#pragma mark ------------------------  private method  ---------------------------
/// 随机 id
- (NSString *)getRandomId {
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *dateStamp = [NSString stringWithFormat:@"%lld", recordTime];
    srand((unsigned)time(0)); //不加这句每次产生的随机数不变
    int time = (int)(100000 + (arc4random() % (999999 - 100000 + 1)));
    NSString *randomId = [NSString stringWithFormat:@"%d",time];
    return [dateStamp stringByAppendingString:randomId];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [super setValue:value forUndefinedKey:key];
}
- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (NSString *)debugDescription {
    //判断是否时NSArray 或者NSDictionary NSNumber 如果是的话直接返回 debugDescription
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]] || [self isKindOfClass:[NSString class]] || [self isKindOfClass:[NSNumber class]]) {
        return [self debugDescription];
    }
    //声明一个字典
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    //得到当前class的所有属性
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    //循环并用KVC得到每个属性的值
    for (int i = 0; i<count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name]?:@"";//默认值为nil字符串
        [dictionary setObject:value forKey:name];//装载到字典里
    }
    //释放
    free(properties);
    //return
    return [NSString stringWithFormat:@"<%@: %p> -- %@",[self class], self, dictionary];
}
@end
