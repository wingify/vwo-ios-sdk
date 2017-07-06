//
//  NSDictionary+Extras.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 28/06/17.
//
//

#import "NSDictionary+VWO.h"

@implementation NSDictionary (VWO)
- (nullable NSString*)toString {
    NSError *error;
    NSData *currentData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

/// Returns YES only if it contains all the keys in parameter
- (BOOL)hasKeys:(NSArray<NSString *> *)keys {
    for (NSString *key in keys) {
        if ([self objectForKey:key] == nil) {
            return NO;
        }
    }
    return YES;
}
@end
