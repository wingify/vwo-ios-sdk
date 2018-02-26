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

- (VWOComparisonResult)compareVersion:(NSString *)targetVersion {
    if (self.length == 0) { return VWOComparisonResultInvalid; }
    if (targetVersion.length == 0) { return VWOComparisonResultInvalid; }

    NSArray *currentArray = [self componentsSeparatedByString:@"."];
    NSArray *targetArray = [targetVersion componentsSeparatedByString:@"."];

    for (int i = 0; i < currentArray.count || i < targetArray.count; i++) {
        int a = (i < currentArray.count) ? [currentArray[i] intValue] : 0;
        int b = (i < targetArray.count) ? [targetArray[i] intValue] : 0;

        if (a < b) { return VWOComparisonResultLesser; }
        if (a > b) { return VWOComparisonResultGreater; }
    }

    return VWOComparisonResultEqual;
}

@end
