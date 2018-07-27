//
//  VSCache.h
//
//
//  Created by Viacheslav Soroka on 7/23/18.
//  Copyright © 2018 Viacheslav Soroka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef id<NSCopying, NSCoding> VSKeyType;

NS_ASSUME_NONNULL_BEGIN

@interface VSCache : NSObject
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, assign) NSUInteger countLimit;

+ (instancetype)sharedCache;

- (void)setObject:(nullable id)object forKey:(VSKeyType)key;

- (void)removeObjectForKey:(VSKeyType)key;
- (void)removeObject:(id)object;
- (void)removeAllObjects;

- (nullable id)objectForKey:(VSKeyType)key;

- (NSEnumerator *)objectEnumerator;
- (NSEnumerator<VSKeyType> *)keyEnumerator;

@end

NS_ASSUME_NONNULL_END
