//
//  VWOStack.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

#import "VWOStack.h"

@interface VWOStack ()
@property (nonatomic, strong) NSMutableArray *contents;
@end

@implementation VWOStack

- (id)init {
    if (self = [super init]) {
        _contents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count {
    return _contents.count;
}

- (void)push:(id)object {
    if (object) {
        [_contents addObject:object];
    }
}

- (id)pop {
    if (_contents.count > 0) {
        id object = _contents.lastObject;
        [_contents removeLastObject];
        return object;
    }
    return nil;
}

- (id)peek {
    if (_contents.count > 0) {
        return _contents.lastObject;
    }
    return nil;
}

- (BOOL)isEmpty {
    return _contents.count == 0;
}

- (void)clear {
    [_contents removeAllObjects];
}

- (NSString *)description {
    return [_contents componentsJoinedByString:@","];
}
@end
