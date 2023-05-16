//
//  Mapping.m
//  VWO
//
//  Created by Harsh Raghav on 12/05/23.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"
#import "VWOConstants.h"

@implementation Mapping

- (void)setGroup:(NSString *)group {
    _group = group;
}

- (void)setTestKey:(NSString *)testKey {
    _testKey = testKey;
}

- (void)setWinnerCampaign:(NSString *)winnerCampaign {
    _winnerCampaign = winnerCampaign;
}

- (BOOL)isSameAs:(Mapping *)mapping {
    if(_group != mapping.group){
        return false;
    }
    if(_testKey != mapping.testKey){
        return false;
    }
    if(_winnerCampaign != mapping.winnerCampaign){
        return false;
    }
    return true;
}

- (NSDictionary *)getAsJson {
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    if (_group == nil) {
        [json setObject:@"" forKey:KEY_GROUP];
    } else {
        [json setObject:_group forKey:KEY_GROUP];
    }
    
    if (_testKey == nil) {
        [json setObject:@"" forKey:KEY_TEST_KEY];
    } else {
        [json setObject:_testKey forKey:KEY_TEST_KEY];
    }
    
    if (_winnerCampaign == nil) {
        [json setObject:@"" forKey:KEY_WINNER_CAMPAIGN];
    } else {
        [json setObject:_winnerCampaign forKey:KEY_WINNER_CAMPAIGN];
    }
    
    return [NSDictionary dictionaryWithDictionary:json];
}

@end
