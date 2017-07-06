//
//  VAOGoal.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOGoal.h"
#import "NSDictionary+VWO.h"

static NSString * kId = @"id";
static NSString * kIdentifier = @"identifier";
static NSString * kType = @"type";

@implementation VAOGoal

- (instancetype)initWithNSDictionary:(NSDictionary *) goalDict {
    self = [super init];
    if (self) {
        if ([goalDict hasKeys:@[kId, kIdentifier]]) {
            [self setId:[goalDict[kId] intValue]];
            [self setIdentifier:kIdentifier];

            NSString *typeString = goalDict[kType];
            if ([typeString isEqualToString:@"@CUSTOM_GOAL"]) {
                [self setType:GoalTypeCustom];
            } else if([typeString isEqualToString:@"REVENUE_TRACKING"]) {
                [self setType:GoalTypeRevenue];
            }
        }
    }
    return self;
}

@end
