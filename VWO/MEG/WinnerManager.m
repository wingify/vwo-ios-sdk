//
//  WinnerManager.m
//  VWO
//
//  Created by Harsh Raghav on 09/05/23.
//

#import <Foundation/Foundation.h>
#import "WinnerManager.h"
#import "Mapping.h"
#import "Winner.h"
#import "Pair.h"
#import "Response.h"
#import "VWOUserDefaults.h"
#import "VWOConstants.h"

@implementation WinnerManager

static NSString *const KEY_SAVED_ARRAY_OF_WINNER_CAMPAIGNS = @"winner_mappings";

- (BOOL)isEmpty:(NSArray *)root {
    return (root.count == 0);
}

- (Response *)getSavedDetailsFor:(NSString *)userId args:(NSDictionary<NSString *,NSString *> *)args {
    @try {
        // check if this user is present locally
        NSString *previousWinnerLocalData = [VWOUserDefaults objectForKey:KEY_SAVED_ARRAY_OF_WINNER_CAMPAIGNS];
        NSInteger userIndex = [self getIndexIfUserExist:userId previousWinnerLocalData:previousWinnerLocalData];
        if (userIndex == -1) {
            Response *response = [[Response alloc] init];
            response.newUser = YES;
            return response;
        }
        NSArray *root = [NSJSONSerialization JSONObjectWithData:[previousWinnerLocalData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSDictionary *user = [root objectAtIndex:userIndex];
        Winner *winner = [[[Winner alloc] init] fromJSONObject:user];

        // prepare groupId and test_key
        NSString *nonConstID_GROUP = [ID_GROUP copy];
        NSString *groupId = [args objectForKey:nonConstID_GROUP];
        NSString *testKey = nil;

        if (groupId == nil) {
            // test_key will only be applicable when there is no groupId
            NSString *nonConstKEY_TEST_KEY = [KEY_TEST_KEY copy];
            testKey = [args objectForKey:nonConstKEY_TEST_KEY];
        }

        Mapping *mapping = [self prepareWinnerMappingUsing:groupId testKey:testKey winnerCampaign:nil];
        Pair *remarkWithResult = [winner getRemarkForUserArgs:mapping args:args];

        LocalUserSearchRemark remark = remarkWithResult.first.integerValue;
        if (remark == ShouldReturnWinnerCampaign) {
            Response *response = [[Response alloc] init];
            response.newUser = NO;
            response.shouldServePreviousWinnerCampaign = YES;
            response.winnerCampaign = (NSString *)remarkWithResult.second;
            return response;
        } else if (remark == ShouldReturnNull) {
            Response *response = [[Response alloc] init];
            response.newUser = NO;
            response.shouldServePreviousWinnerCampaign = YES;
            response.winnerCampaign = nil;
            return response;
        } else {
            // treat this block as -> (Winner_LocalUserSearchRemark_NOT_FOUND_FOR_PASSED_ARGS)
            // we did not find anything related to the provided args
            // we should treat this like a new user and MEG should be applied.
            Response *response = [[Response alloc] init];
            response.newUser = YES;
            response.shouldServePreviousWinnerCampaign = NO;
            response.winnerCampaign = nil;
            return response;
        }
    } @catch (NSException *exception) {
        return nil;
    }
}

- (BOOL)save:(NSString *)userId winnerCampaign:(NSString *)winnerCampaign args:(NSDictionary<NSString *, NSString *> *)args {
    @try {
        [self saveThrowingException:userId winnerCampaign:winnerCampaign args:args];
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
}

- (void)saveThrowingException:(NSString *)userId winnerCampaign:(NSString *)winnerCampaign args:(NSDictionary<NSString *, NSString *> *)args {
    NSMutableArray<NSDictionary *> *root = [[NSMutableArray alloc] init];
    
    // check for existing data in the shared preferences
    NSString *previousWinnerLocalData = [VWOUserDefaults objectForKey:KEY_SAVED_ARRAY_OF_WINNER_CAMPAIGNS];
    if (![previousWinnerLocalData isEqualToString:@""]) {
        NSError *jsonError = nil;
        root = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:[previousWinnerLocalData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError]];
        if (jsonError) {
            return;
        }
    }
    
    // if there is groupId then campaign will be ignored altogether
    NSString *nonConstID_GROUP = [ID_GROUP copy];
    NSString *groupId = [args objectForKey:nonConstID_GROUP];
    NSString *testKey = nil;
    
    if (groupId == nil) {
        // test_key will only be applicable when there is no groupId
        NSString *nonConstKEY_TEST_KEY = [KEY_TEST_KEY copy];
        testKey = [args objectForKey:nonConstKEY_TEST_KEY];
    }
    
    if ([root count] == 0) {
        Winner *firstWinner = [self prepareWinnerUsing:userId winnerCampaign:winnerCampaign groupId:groupId testKey:testKey];
        [root addObject:[firstWinner getJSONObject]];
        [self storeLocally:root];
        return;
    }
    
    NSInteger index = [self getIndexIfUserExist:userId previousWinnerLocalData:previousWinnerLocalData];
    if (index == -1) {
        // this user didn't exist treat as new
        Winner *firstWinner = [self prepareWinnerUsing:userId winnerCampaign:winnerCampaign groupId:groupId testKey:testKey];
        [root addObject:[firstWinner getJSONObject]];
        [self storeLocally:root];
        return;
    }
    
    // existing user exist at index simply update that index
    NSDictionary *current = [root objectAtIndex:index];
    Winner *currentWinner = [[[Winner alloc] init] fromJSONObject:current];
    
    // try to add new values if it doesn't already exist
    Mapping *mapping = [self prepareWinnerMappingUsing:groupId testKey:testKey winnerCampaign:winnerCampaign];
    [currentWinner addMapping:mapping];
    
    // replace with new value just in case
    [root replaceObjectAtIndex:index withObject:[currentWinner getJSONObject]];
    [self storeLocally:root];
}

- (void)storeLocally:(NSArray *)root {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [VWOUserDefaults setObject:jsonString forKey:KEY_SAVED_ARRAY_OF_WINNER_CAMPAIGNS];
}

- (NSInteger)getIndexIfUserExist:(NSString *)userId previousWinnerLocalData:(NSString *)previousWinnerLocalData {
    NSInteger index = -1;
    NSError *error;
    NSData *jsonData = [previousWinnerLocalData dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error == nil) {
        for (int i = 0; i < [jsonArray count]; i++) {
            NSDictionary *current = [jsonArray objectAtIndex:i];
//            [jMapping objectForKey:KEY_TEST_KEY]
            if ([[current objectForKey:KEY_USER] isEqualToString:userId]) {
                index = i;
                break;
            }
        }
    }
    return index;
}

- (Winner *)prepareWinnerUsing:(NSString *)userId winnerCampaign:(NSString *)winnerCampaign groupId:(NSString *)groupId testKey:(NSString *)testKey {
    Winner *winner = [[Winner alloc] init];
    [winner setUser:userId];

    Mapping *mapping = [self prepareWinnerMappingUsing:groupId testKey:testKey winnerCampaign:winnerCampaign];
    [winner addMapping:mapping];

    return winner;
}

- (Mapping *)prepareWinnerMappingUsing:(NSString *)groupId testKey:(NSString *)testKey winnerCampaign:(NSString *)winnerCampaign {
    Mapping *mapping = [[Mapping alloc] init];
    [mapping setGroup:groupId];
    [mapping setTestKey:testKey];
    [mapping setWinnerCampaign:winnerCampaign];
    return mapping;
}

@end
