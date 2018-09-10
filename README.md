## VSCache

A simple thread-safe cache with ability to enumerate all keys and object.

## Features

  - Automatic cleanup when too few system memory is left
  - Automatic removing the oldest items when `countLimit` is excided
  - Thread-safe
  - Enumerating keys and objects

## Usage:
#### Basic usage
```objective-c
VSCache *cache = [VSCache new];
cache.countLimit = 50;

NSString *key = @"someKey";
[cache setObject:[NSObject new] forKey:key];
NSObject *value = [cache objectForKey:key];
```

#### Enumeration
```objective-c
VSCache *cache = ...
NSEnumerator *objectEnumerator = [cache objectEnumerator];
for (id object in objectEnumerator) {
    ...
}

NSEnumerator *keyEnumerator = [cache keyEnumerator];
for (id key in keyEnumerator) {
    ...
}
```

## License
VSCache is available under the MIT license. See the LICENSE file for more info.
