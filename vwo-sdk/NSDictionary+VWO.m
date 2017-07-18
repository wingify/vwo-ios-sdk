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

- (NSArray<NSString *>*) keysMissingFrom:(NSArray<NSString *> *)mustHaveKeys {
    NSMutableArray *mustHaveKeysMutable = mustHaveKeys.mutableCopy;
    [mustHaveKeysMutable removeObjectsInArray:self.allKeys];
    return mustHaveKeysMutable;
}
@end
