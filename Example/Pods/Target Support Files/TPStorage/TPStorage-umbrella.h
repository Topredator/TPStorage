#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TPStorageConfig.h"
#import "TPStorageTableMap.h"
#import "TPStorageDBModel.h"
#import "TPStorageOperator+Delete.h"
#import "TPStorageOperator+Insert.h"
#import "TPStorageOperator+Query.h"
#import "TPStorageOperator+Update.h"
#import "TPStorageOperator.h"
#import "TPStorage.h"
#import "TPStorageEngine.h"

FOUNDATION_EXPORT double TPStorageVersionNumber;
FOUNDATION_EXPORT const unsigned char TPStorageVersionString[];

