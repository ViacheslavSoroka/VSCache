//
//  VSCache.h
//
//
//  Created by Viacheslav Soroka on 7/23/18.
//  Copyright © 2018 Viacheslav Soroka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VSCache <KeyType, ObjectType> : NSObject
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, assign) NSUInteger countLimit;

+ (instancetype)sharedCache;

- (void)setObject:(nullable ObjectType)object forKey:(KeyType)key;

- (void)removeObjectForKey:(KeyType)key;
- (void)removeObject:(ObjectType)object;
- (void)removeAllObjects;

- (nullable ObjectType)objectForKey:(KeyType)key;

- (NSEnumerator<ObjectType> *)objectEnumerator;
- (NSEnumerator<KeyType> *)keyEnumerator;

@end

NS_ASSUME_NONNULL_END
