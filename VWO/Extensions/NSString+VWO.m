//
//  NSString+VWO.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 17/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "NSString+VWO.h"

@implementation NSString(Version)
    //Converts version in X.y format
- (NSString *)toXDotY {
    NSArray *currentArray = [self componentsSeparatedByString:@"."];
    NSMutableString *formattedVersion = [NSMutableString new];
    if (currentArray.firstObject) {
        [formattedVersion appendString:currentArray.firstObject];
    }
    if (currentArray.count > 1) {
        [formattedVersion appendString:@"."];
        [formattedVersion appendString:currentArray[1]];
    } else {
        [formattedVersion appendString:@".0"];
    }
    return formattedVersion;
}
@end
