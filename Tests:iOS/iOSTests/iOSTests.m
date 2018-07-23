//
//  iOSTests.m
//  iOSTests
//
//  Created by Viacheslav Soroka on 7/23/18.
//  Copyright © 2018 Viacheslav Soroka. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VSCache.h"

@implementation iOSTests: XCTestCase

- (void)testCountLimit {
    NSInteger countLimit = 20;
    VSCache *cache = [self cacheWithObjectsCount:265 countLimit:countLimit];
    
    XCTAssert([[[cache objectEnumerator] allObjects] count] == countLimit);
}

- (void)testObjectOrder {
    VSCache *cache = [VSCache new];
    cache.countLimit = 20;
    
    NSString *first = @"first";
    [cache setObject:[NSObject new] forKey:first];
    
    [self fillCache:cache withObjectsCount:20];
    
    NSString *last = @"last";
    [cache setObject:[NSObject new] forKey:last];
    
    XCTAssert(![cache objectForKey:first]);
    XCTAssert([cache objectForKey:last]);
}

- (void)testCountLimitChanges {
    VSCache *cache = [self cacheWithObjectsCount:20 countLimit:20];
    
    XCTAssert([[[cache objectEnumerator] allObjects] count] == 20);
    
    cache.countLimit = 10;
    
    XCTAssert([[[cache objectEnumerator] allObjects] count] == 10);
    
    cache.countLimit = 20;
    
    [cache setObject:[NSObject new] forKey:@"obj"];
    
    XCTAssert([[[cache objectEnumerator] allObjects] count] == 11);
}

- (void)testMemoryWarning {
    VSCache *cache = [VSCache new];
    cache.countLimit = 20;
    
    [self fillCache:cache withObjectsCount:20];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification
                                                        object:nil];
    
    XCTAssert(![[[cache objectEnumerator] allObjects] count]);
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