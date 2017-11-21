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

- (NSString *)toString {
    NSError *error;
    NSData *currentData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSArray<NSURLQueryItem *> *)toQueryItems {
    NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray new];
    for (NSString *key in self) {
        NSAssert([self[key] isKindOfClass:[NSString class]], @"Query item can only have string");
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:self[key]];
        [queryItems addObject:item];
    }
    return queryItems;
}

@end
