//
//  NSDictionary+Extras.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 28/06/17.
//
//

#import "NSDictionary+VWO.h"

@implementation NSDictionary (VWO)

- (NSArray<NSString *> *) keysMissingFrom:(NSArray<NSString *> *)mustHaveKeys {
    NSMutableArray *mustHaveKeysMutable = mustHaveKeys.mutableCopy;
    [mustHaveKeysMutable removeObjectsInArray:self.allKeys];
    return mustHaveKeysMutable;
}

@end
