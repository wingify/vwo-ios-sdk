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
#import "VWOConstants.h"

static NSString * kId          = @"id";
static NSString * kType        = @"type";
static NSString * kIdentifier  = @"identifier";
static NSString * kRevenueProp = @"revenueProp";
static NSString * kMca         = @"mca";
@implementation VWOGoal

- (instancetype)initWithId:(int)iD identifier:(NSString *)identifier type:(GoalType)type revenueProp:(NSString *)revenueProp mca:(int)mca{
    NSParameterAssert(identifier);
    self = [super init];
    if (self) {
        self.iD          = iD;
        self.identifier  = identifier;
        self.type        = type;
        self.revenueProp = revenueProp;
        self.mca         = mca;
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
    
    NSString *nonConstRevenueTracking = [ConstRevenueTracking copy];
    if([goalDict[kType] isEqualToString:nonConstRevenueTracking]) {
        type = GoalTypeRevenue;
        revenueProp = goalDict[kRevenueProp];
    }

    int mca = [goalDict[kMca] intValue];
    return [self initWithId:id identifier:identifier type:type revenueProp:revenueProp mca:mca];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(id: %d)", self.identifier, self.iD];
}

@end
