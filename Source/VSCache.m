//
//  VSCache.h
//
//
//  Created by Viacheslav Soroka on 7/23/18.
//  Copyright © 2018 Viacheslav Soroka. All rights reserved.
//

#import "VSCache.h"

static const NSUInteger kVSDefaultCountLimit = 50;

@interface VSCache ()
@property (nonatomic, strong) NSMutableDictionary *objects;
@property (nonatomic, strong) NSMutableArray *keys;

@end

@implementation VSCache

#pragma mark - Class Methods

+ (instancetype)sharedCache {
    static VSCache *cache = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        cache = [self new];
    });
    
    return cache;
}

#pragma mark - Initialisations and Deallocations

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.objects = [NSMutableDictionary dictionary];
        self.keys = [NSMutableArray array];
        self.countLimit = kVSDefaultCountLimit;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationDidReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Accessors

- (NSUInteger)count {
    @synchronized(self) {
        return self.objects.count;
    }
}

- (void)setCountLimit:(NSUInteger)countLimit {
    if (_countLimit != countLimit) {
        _countLimit = countLimit;
        
        [self cleanupWithCountLimit:countLimit];
    }
}

#pragma mark - Public Methods

- (void)setObject:(id)object forKey:(id)key {
    @synchronized(self) {
        [self.objects setObject:object forKey:key];
        NSMutableArray *keys = self.keys;
        if (object) {
            if ([keys containsObject:key]) {
                [keys removeObject:key];
            }
            
            [keys addObject:key];
        }
        else {
            [keys removeObject:key];
        }
        
        [self cleanupWithCountLimit:self.countLimit];
    }
}

- (void)removeObjectForKey:(id)key {
    @synchronized(self) {
        [self.objects removeObjectForKey:key];
        [self.keys removeObject:key];
    }
}

- (void)removeObject:(id)object {
    @synchronized(self) {
        NSMutableDictionary *objects = self.objects;
        NSEnumerator *enumerator = [[objects copy] keyEnumerator];
        id key = nil;
        
        for (id cachedKey in enumerator) {
            if (object == [objects objectForKey:cachedKey]) {
                key = cachedKey;
            }
        }
        
        if (key) {
            [objects removeObjectForKey:key];
            [self.keys removeObject:key];
        }
    }
}

- (void)removeAllObjects {
    @synchronized(self) {
        [self.objects removeAllObjects];
        [self.keys removeAllObjects];
    }
}

- (id)objectForKey:(id)key {
    @synchronized(self) {
        return [self.objects objectForKey:key];
    }
}

- (NSEnumerator *)objectEnumerator {
    @synchronized(self) {
        return [[self.objects copy] objectEnumerator];
    }
}

- (NSEnumerator *)keyEnumerator {
    @synchronized(self) {
        return [[self.objects copy] keyEnumerator];
    }
}

#pragma mark - Private Methods

- (void)cleanupWithCountLimit:(NSInteger)countLimit {
    @synchronized(self) {
        NSMutableArray *keys = self.keys;
        NSMutableDictionary *objects = self.objects;
        while ((keys.count > countLimit) && keys.count) {
            id key = [keys firstObject];
            id object = objects[key];

            [_delegate cache:self willEvictObject:object];

            [keys removeObjectAtIndex:0];
            [objects removeObjectForKey:key];
        }
    }
}

#pragma mark - Notifications

- (void)onApplicationDidReceiveMemoryWarning:(NSNotification *)notification {
    [self removeAllObjects];
}

@end
