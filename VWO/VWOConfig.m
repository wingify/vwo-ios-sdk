//
//  VWOUserConfig.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 29/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import "VWOConfig.h"

@implementation VWOConfig

- (NSString *)description {
    return [NSString stringWithFormat:@"Optout: %@\nPreviewDisabled: %@\nUserID: %@\n%@",
            self.optOut ? @"YES" : @"NO",
            self.disablePreview ? @"YES" : @"NO",
            self.userID,
            self.customVariables];
}

- (void) setCustomDimension:(nonnull NSString *)customDimensionKey withCustomDimensionValue:(nonnull NSString *)customDimensionValue {
    NSAssert(customDimensionKey.length != 0, @"CustomDimensionKey cannot be empty");
    NSAssert(customDimensionValue.length != 0, @"customDimensionValue cannot be empty");
    _customDimension = [NSString stringWithFormat:@"{\"u\":{\"%@\":\"%@\"}}", customDimensionKey, customDimensionValue];
}
@end
