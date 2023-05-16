//
//  Winner.m
//  VWO
//
//  Created by Harsh Raghav on 05/05/23.
//

#import <Foundation/Foundation.h>
#import "VWOConstants.h"
#import "Winner.h"
#import "Pair.h"
#import "Mapping.h"
#import "VWOLogger.h"

@implementation Winner
NSString *user;

NSMutableArray<Mapping *> *mappings;

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialize private properties
        mappings = [NSMutableArray array];
    }
    return self;
}

- (Winner *)fromJSONObject:(NSDictionary *)jsonObject {
    Winner *winner = [[Winner alloc] init];
    
    @try {
        winner.user = [jsonObject objectForKey:KEY_USER];
        mappings = [[NSMutableArray alloc] init];
        
        NSArray *jMappings = [jsonObject objectForKey:KEY_MAPPING];
        NSInteger jMappingSize = jMappings.count;
        for (int i = 0; i < jMappingSize; i++) {
            NSDictionary *jMapping = [jMappings objectAtIndex:i];
            
            Mapping *_mapping = [[Mapping alloc] init];
            _mapping.testKey = [jMapping objectForKey:KEY_TEST_KEY];
            _mapping.group = [jMapping objectForKey:KEY_GROUP];
            _mapping.winnerCampaign = [jMapping objectForKey:KEY_WINNER_CAMPAIGN];

            [mappings addObject:_mapping];
        }
    } @catch (NSException *exception) {
        // Handle the exception
        VWOLogDebug(@"MutuallyExclusive  %@", exception);
    }
    
    return winner;
}

- (void)setUser:(NSString *)user {
    _user = user;
}

- (void)addMapping:(Mapping *)mapping {
    NSLog(@"%@", [mapping getAsJson]);

    BOOL found = NO;
    for (Mapping *m in mappings) {
        if ([m isSameAs:mapping]) {
            found = YES;
            break;
        }
    }

    if (!found) {
        [mappings addObject:mapping];
    }
}

- (NSDictionary *)getJSONObject {
    NSMutableDictionary *json = [NSMutableDictionary new];
    if (user != nil) {
        [json setValue:user forKey:@"user"];
    }
    
    NSMutableArray *mappingArray = [NSMutableArray new];
    for (Mapping *mapping in mappings) {
        NSDictionary *mappingJson = [mapping getAsJson];
        if (mappingJson != nil) {
            [mappingArray addObject:mappingJson];
        }
    }
    
    if (mappingArray.count > 0) {
        [json setValue:mappingArray forKey:@"mapping"];
    }
    
    return json;
}

- (Pair *)getRemarkForUserArgs:(Mapping *)mapping args:(NSDictionary<NSString *, NSString *> *)args {

    BOOL isGroupIdPresent = ![args[ID_GROUP] isEqualToString:@""];
    BOOL isTestKeyPresent = ![args[TEST_KEY] isEqualToString:@""];

    if (!isGroupIdPresent && !isTestKeyPresent) {
        // there's no point in evaluating the stored values if both are null
        // as this is a user error
        LocalUserSearchRemark local = NotFoundForPassedArgs;
        return [[Pair alloc] initWithFirst:@(NotFoundForPassedArgs) second:@""];
    }

    NSString *empty = @"";

    for (Mapping *m in mappings) {

        // because "" = null for mappings
        NSString *group = [empty isEqualToString:[m group]] ? nil : [m group];

        BOOL isGroupSame = [group isEqualToString:[mapping group]];
        BOOL isTestKeySame = [[m testKey] isEqualToString:[m testKey]];

        if (isGroupIdPresent && isGroupSame) {
            // cond 1. if { groupId } is PRESENT then there is no need to check for the { test_key }
            if ([empty isEqualToString:[m winnerCampaign]]) {
                return [[Pair alloc] initWithFirst:@(ShouldReturnNull) second:@""];
            }
            return [[Pair alloc] initWithFirst:@(ShouldReturnWinnerCampaign) second:@""];
        } else if (!isGroupIdPresent && isTestKeySame) {
            // cond 2. if { groupId } is NOT PRESENT then then check for the { test_key }
            if ([empty isEqualToString:[m testKey]]) {
                return [[Pair alloc] initWithFirst:@(ShouldReturnNull) second:@""];
            }
            return [[Pair alloc] initWithFirst:@(ShouldReturnWinnerCampaign) second:[m winnerCampaign]];
        }
    }
    return [[Pair alloc] initWithFirst:@(NotFoundForPassedArgs) second:@""];
}

@end
