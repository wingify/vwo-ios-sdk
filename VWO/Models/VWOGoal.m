//
//  VWOGoal.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VWOGoal.h"
#import "NSDictionary+VWO.h"
#import "VWOLogger.h"

static NSString * kId          = @"id";
static NSString * kType        = @"type";
static NSString * kIdentifier  = @"identifier";
static NSString * kRevenueProp = @"revenueProp";
@implementation VWOGoal

- (instancetype)initWithId:(int)iD identifier:(NSString *)identifier type:(GoalType)type revenueProp:(NSString *)revenueProp {
    NSParameterAssert(identifier);
    self = [super init];
    if (self) {
        self.iD          = iD;
        self.identifier  = identifier;
        self.type        = type;
        self.revenueProp = revenueProp;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)goalDict {
    NSParameterAssert(goalDict);

    NSArray *missingKeys = [goalDict keysMissingFrom:@[kId, kIdentifier]];
    if (missingKeys.count > 0) {
        VWOLogException(@"Keys missing [%@] for Goal JSON {%@}", [missingKeys componentsJoinedByString:@", "], goalDict);
        return nil;
    }

    int id = [goalDict[kId] intValue];
    NSString *identifier = goalDict[kIdentifier];

    GoalType type = GoalTypeCustom;
    NSString *revenueProp = @"";
    if([goalDict[kType] isEqualToString:@"REVENUE_TRACKING"]) {
        type = GoalTypeRevenue;
        revenueProp = goalDict[kRevenueProp];
    }

    return [self initWithId:id identifier:identifier type:type revenueProp:revenueProp];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(id: %d)", self.identifier, self.iD];
}

@end
