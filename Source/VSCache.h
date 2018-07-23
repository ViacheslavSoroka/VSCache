//
//  VSCache.h
//
//
//  Created by Viacheslav Soroka on 7/23/18.
//  Copyright © 2018 Viacheslav Soroka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef id<NSCopying, NSCoding> PRKeyType;

NS_ASSUME_NONNULL_BEGIN

@interface VSCache : NSObject
@property (nonatomic, assign) NSUInteger countLimit;

+ (instancetype)sharedCache;

- (void)setObject:(nullable id)object forKey:(PRKeyType)key;

- (void)removeObjectForKey:(PRKeyType)key;
- (void)removeObject:(id)object;
- (void)removeAllObjects;

- (nullable id)objectForKey:(PRKeyType)key;

- (NSEnumerator *)objectEnumerator;
- (NSEnumerator<PRKeyType> *)keyEnumerator;

@end

NS_ASSUME_NONNULL_END
