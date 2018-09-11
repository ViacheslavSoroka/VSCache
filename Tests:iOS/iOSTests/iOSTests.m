//
//  iOSTests.m
//  iOSTests
//
//  Created by Viacheslav Soroka on 7/23/18.
//  Copyright © 2018 Viacheslav Soroka. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VSCache.h"

#define SuppressPerformSelectorLeakWarning(code) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
code; \
_Pragma("clang diagnostic pop") \

static const NSInteger kVSDefaultCacheSize = 20;

@interface iOSTests : XCTestCase

@end

@implementation iOSTests: XCTestCase

- (void)testCountLimit {
    const NSInteger count = kVSDefaultCacheSize;
    VSCache *cache = [self cacheWithObjectsCount:count + 1 countLimit:count];
    
    XCTAssert(cache.count == count);
}

- (void)testObjectOrder {
    const NSInteger count = kVSDefaultCacheSize;
    
    VSCache *cache = [VSCache new];
    cache.countLimit = count;
    
    NSString * const first = @"first";
    [cache setObject:[NSObject new] forKey:first];
    
    [self fillCache:cache withObjectsCount:count];
    
    NSString * const last = @"last";
    [cache setObject:[NSObject new] forKey:last];
    
    XCTAssert(![cache objectForKey:first]);
    XCTAssert([cache objectForKey:last]);
}

- (void)testCountLimitChanges {
    const NSInteger defaultCount = kVSDefaultCacheSize;
    const NSInteger halfCount = defaultCount / 2;
    VSCache *cache = [self cacheWithObjectsCount:defaultCount countLimit:defaultCount];
    
    XCTAssert(cache.count == defaultCount);
    
    cache.countLimit = halfCount;
    
    XCTAssert(cache.count == halfCount);
    
    cache.countLimit = defaultCount;
    
    [cache setObject:[NSObject new] forKey:@"obj"];
    
    XCTAssert(cache.count == (halfCount + 1));
}

- (void)testMemoryWarning {
    const NSInteger count = kVSDefaultCacheSize;
    VSCache *cache = [self cacheWithObjectsCount:count countLimit:count];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification
                                                        object:nil];
    
    XCTAssert(!cache.count);
}

- (void)testForThreadSafeEnumeration {
    __auto_type iterateAndMutate = ^void(NSEnumerator *enumerator, SEL selector, VSCache *cache) {
        dispatch_group_t group = dispatch_group_create();
        for (id obj in enumerator) {
            dispatch_group_enter(group);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                SuppressPerformSelectorLeakWarning(
                    [cache performSelector:selector withObject:obj];
                );
                
                dispatch_group_leave(group);
            });
        }
        
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_SEC)));
    };
    
    const NSInteger count = kVSDefaultCacheSize;
    @try {
        VSCache *cache = [self cacheWithObjectsCount:count countLimit:count];
        iterateAndMutate([cache objectEnumerator], @selector(removeObject:), cache);
        iterateAndMutate([cache keyEnumerator], @selector(removeObjectForKey:), cache);
    }
    @catch (NSException *exc) {
        XCTFail(@"Exception: %@", exc);
    }
}

- (void)testForThreadSafeWork {
    const NSInteger count = kVSDefaultCacheSize;
    VSCache *cache = [self cacheWithObjectsCount:count countLimit:count];
    
    const NSInteger numberOfThreads = 10;
    const NSInteger numberOfIterations = 100;
    
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger count = 0; count < numberOfThreads; count++) {
        dispatch_group_enter(group);
        
        const char *label = [[NSString stringWithFormat:@"test.%ld", count] UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            for (NSInteger index = 0; index < numberOfIterations; index++) {
                [cache setObject:[NSObject new] forKey:[NSUUID UUID].UUIDString];
                [cache objectForKey:[NSUUID UUID].UUIDString];
            }
            
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_SEC)));
}

#pragma mark - Private Methods

- (VSCache *)cacheWithObjectsCount:(NSInteger)count countLimit:(NSInteger)countLimit {
    VSCache *cache = [VSCache new];
    cache.countLimit = countLimit;
    
    [self fillCache:cache withObjectsCount:count];
    
    return cache;
}

- (void)fillCache:(VSCache *)cache withObjectsCount:(NSInteger)count {
    for (NSInteger index = 0; index < count; index++) {
        NSObject *object = [NSObject new];
        [cache setObject:object forKey:[NSString stringWithFormat:@"%p", object]];
    }
}

@end
