//
//  VAOGoal.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOGoal.h"
#import "NSDictionary+VWO.h"

NSString * const kId = @"id";
NSString * const kIdentifier = @"identifier";
NSString * const kType = @"type";


@implementation VAOGoal

- (instancetype)initWithNSDictionary:(NSDictionary *) goalDict {
    self = [super init];
    if (self) {
        if ([goalDict hasKey:kId] && [goalDict hasKey:kIdentifier]) {
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
