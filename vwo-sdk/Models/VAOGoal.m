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

- (instancetype)initWithId:(int) iD identifier:(NSString *)identifier type:(GoalType) type {
    NSParameterAssert(identifier);
    self = [super init];
    if (self) {
        self.iD = iD;
        self.identifier = identifier;
        self.type = type;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *) goalDict {
    NSParameterAssert(goalDict);

    NSArray *missingKeys = [goalDict keysMissingFrom:@[kId, kIdentifier]];
    if (missingKeys.count > 0) {
        NSLog(@"GOAL Keys missing %@", [missingKeys componentsJoinedByString:@", "]);
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
    return [NSString stringWithFormat:@"GOAL: %@(%d)", self.identifier, self.iD];
}

#pragma mark - NSCoding
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    int id = [aDecoder decodeIntForKey:kId];
    NSString *identifier = [aDecoder decodeObjectForKey:kIdentifier];
    GoalType type = [aDecoder decodeIntegerForKey:kType];
    return [self initWithId:id identifier:identifier type:type];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.iD forKey:kId];
    [aCoder encodeObject:self.identifier forKey:kIdentifier];
    [aCoder encodeInteger:self.type forKey:kType];
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone {
    VAOGoal *copy = [[[self class] allocWithZone:zone] init];
    copy.iD = self.iD;
    copy.type = self.type;
    copy.identifier = [self.identifier copyWithZone:zone];
    return copy;
}

@end
