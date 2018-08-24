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
@end
