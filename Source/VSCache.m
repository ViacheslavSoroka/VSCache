//
//  VSCache.h
//
//
//  Created by Viacheslav Soroka on 7/23/18.
//  Copyright © 2018 Viacheslav Soroka. All rights reserved.
//

static const NSUInteger kVSDefaultCountLimit = 50;

#import "VSCache.h"

@interface VSCache ()
@property (nonatomic, strong) NSMutableDictionary *objects;
@property (nonatomic, strong) NSMutableArray<PRKeyType> *keys;

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
        self.countLimit =
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationDidReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setCountLimit:(NSUInteger)countLimit
{
    if (_countLimit != countLimit) {
        _countLimit = countLimit;
        
        [self cleanupWithCountLimit:countLimit];
    }
}

#pragma mark - Public Methods

- (void)setObject:(id)object forKey:(PRKeyType)key {
    @synchronized(self) {
        [self.objects setObject:object forKey:key];
        if (object) {
            if ([self.keys containsObject:key]) {
                [self.keys removeObject:key];
            }
            
            [self.keys addObject:key];
        }
        else {
            [self.keys removeObject:key];
        }
    }
}

- (void)removeObjectForKey:(PRKeyType)key {
    @synchronized(self) {
        [self.objects removeObjectForKey:key];
        [self.keys removeObject:key];
    }
}

- (void)removeObject:(id)object {
    @synchronized(self) {
        NSMutableDictionary *objects = self.objects;
        NSEnumerator *enumerator = [objects keyEnumerator];
        id key;
        
        for (id cachedKey in enumerator) {
            if (object == [objects objectForKey:cachedKey]) {
                key = cachedKey;
            }
        }
        
        [objects removeObjectForKey:key];
        [self.keys removeObject:key];
    }
}

- (void)removeAllObjects {
    @synchronized(self) {
        [self.objects removeAllObjects];
        [self.keys removeAllObjects];
    }
}

- (id)objectForKey:(PRKeyType)key {
    @synchronized(self.objects) {
        return [self.objects objectForKey:key];
    }
}

- (NSEnumerator *)objectEnumerator {
    @synchronized(self.objects) {
        return [self.objects objectEnumerator];
    }
}

- (NSEnumerator *)keyEnumerator {
    @synchronized(self.objects) {
        return [self.objects keyEnumerator];
    }
}

#pragma mark - Private Methods

- (void)cleanupWithCountLimit:(NSInteger)countLimit
{
    
}

#pragma mark - Notifications

- (void)onApplicationDidReceiveMemoryWarning:(NSNotification *)notification {
    [self removeAllObjects];
}

@end
