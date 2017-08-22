//
//  Objc_Test.m
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 22/08/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

#import "Objc_Test.h"
#import "VWO.h"

@implementation Objc_Test

-(void)foo {
    [NSNotificationCenter.defaultCenter addObserverForName:VWOUserStartedTrackingInCampaignNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
    }];
}
@end
