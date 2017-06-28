//
//  NSDictionary+Extras.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 28/06/17.
//
//

#import "NSDictionary+Extras.h"

@implementation NSDictionary (Extras)
- (nullable NSString*)toString {
    NSError *error;
    NSData *currentData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
