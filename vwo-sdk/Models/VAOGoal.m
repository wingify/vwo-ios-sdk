//
//  VAOGoal.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOGoal.h"
#import "NSDictionary+VWO.h"
#import "VAOLogger.h"

static NSString * kId         = @"id";
static NSString * kType       = @"type";
static NSString * kIdentifier = @"identifier";

@implementation VAOGoal

- (instancetype)initWithId:(int) iD identifier:(NSString *)identifier type:(GoalType) type {
    NSParameterAssert(identifier);
    self = [super init];
    if (self) {
        self.iD         = iD;
        self.identifier = identifier;
        self.type       = type;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *) goalDict {
    NSParameterAssert(goalDict);

    NSArray *missingKeys = [goalDict keysMissingFrom:@[kId, kIdentifier]];
    if (missingKeys.count > 0) {
        VAOLogException(@"Keys missing [%@] for Goal JSON {%@}", [missingKeys componentsJoinedByString:@", "], goalDict);
        return nil;
    }

    int id = [goalDict[kId] intValue];
    NSString *identifier = goalDict[kIdentifier];

    GoalType type = GoalTypeCustom;
    if ([goalDict[kType] isEqualToString:@"@CUSTOM_GOAL"]) type = GoalTypeCustom;
    else if([goalDict[kType] isEqualToString:@"REVENUE_TRACKING"]) type = GoalTypeRevenue;

    return [self initWithId:id identifier:identifier type:type];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@(%d)", self.identifier, self.iD];
}

@end
