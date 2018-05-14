//
//  VWOUserConfig.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 29/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import "VWOConfig.h"

@implementation VWOConfig

+ (VWOConfig *)defaultConfig {
    VWOConfig *config = [VWOConfig new];
    config.timeout = 60;
    return config;
}

- (NSString *)description {
    return [NSString
            stringWithFormat:@"ForceReload: %@\nOptout: %@\nPreviewDisabled: %@\n%@",
            self.forceReloadCampaingsOnLaunch ? @"YES" : @"NO",
            self.optOut ? @"YES" : @"NO",
            self.disablePreview ? @"YES" : @"NO",
            self.customVariables];
}

@end
