//
//  VAOController.m
//  VAO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOController.h"
#import "VAOModel.h"
#import "VAOAPIClient.h"
#import "VAOSocketClient.h"
#import "VAOGoogleAnalytics.h"
#import "VAORavenClient.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include "VAOSDKInfo.h"
#import "VAOLogger.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static const NSTimeInterval kMinUpdateTimeGap = 60*60; // seconds in 1 hour

typedef NS_ENUM(NSInteger, SegmentationType) {
    SegmentationTypeCustomVariable=7,
    SegmentationTypeAppVersion=6,
    SegmentationTypeiOSVersion=1,
    SegmentationTypeDayOfWeek=3,
    SegmentationTypeHourOfTheDay=4,
    SegmentationTypeLocation=5
};

@implementation VAOController {
    BOOL _remoteDataDownloading;
    NSTimeInterval _lastUpdateTime;
    BOOL _previewMode;
    BOOL _trackUserManually;
    NSMutableDictionary *_campaignInfo; // holds the set of changes to be applied to various UI elements
    NSMutableDictionary *_activeGoals;
    NSMutableDictionary *customVariables;
}

+ (void)initializeAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    [[self sharedInstance] updateCampaignInfo];
    [[self sharedInstance] downloadCampaignAsynchronously:async withCallback:completionBlock];
    [[self sharedInstance] addBackgroundListeners];
}

-(void)addBackgroundListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground)
                               name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground)
                               name:UIApplicationWillEnterForegroundNotification object:nil];
}

+ (instancetype)sharedInstance{
    static VAOController *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _remoteDataDownloading = NO;
        _lastUpdateTime = 0;
        _previewMode = NO;
        _trackUserManually = NO;
        _activeGoals = [[NSMutableDictionary alloc] init];
        customVariables = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)updateCampaignInfo {
    _campaignInfo = [[VAOModel sharedInstance] getCampaignInfo];
}

- (void)setValue:(NSString*)value forCustomVariable:(NSString*)variable {
    if(!value || !variable) return;
    @try {
        [customVariables setObject:value forKey:variable];
    }
    @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
}

- (void)applicationDidEnterBackground {
    if(_previewMode == NO) {
        _lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
        [[VAOAPIClient sharedInstance] stopTimer];
    }
}

- (void)applicationWillEnterForeground {
    [[VAOAPIClient sharedInstance] startTimer];
    if(_remoteDataDownloading == NO) {
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        if(currentTime - _lastUpdateTime < kMinUpdateTimeGap){
            return;
        }
        
        [self downloadCampaignAsynchronously:YES withCallback:nil];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadCampaignAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    _remoteDataDownloading = YES;

    [[VAOAPIClient sharedInstance] pullABDataAsynchronously:async success:^(id responseObject) {
        _lastUpdateTime = currentTime;
        _remoteDataDownloading = NO;

//        [self _updateCampaignInfo:info];
        [[VAOModel sharedInstance] updateCampaignListFromNetworkResponse:responseObject];
        if (completionBlock) {
            completionBlock();
        }
    } failure:^(NSError *error) {
        [VAOLogger errorStr:[NSString stringWithFormat:@"Failed to connect to the VAO server to download AB logs. %@\n", error]];
    }];
}

- (void)applicationDidEnterPreviewMode {
    _previewMode = YES;
}

- (void)applicationDidExitPreviewMode{
    _previewMode = NO;
    
    // we should load
    [self updateCampaignInfo];
}

/**
 *  returns NO if value is nil or [NSNull null]
 */
- (BOOL)hasValidValue:(id)value {
    return (value != nil && value != [NSNull null]);
}

- (void)trackUserManually {
    _trackUserManually = YES;
}

/**
 *  Rewrite Campaign information file.
 */
- (void)_updateCampaignInfo:(NSMutableArray *)newInfo{
    @try {        
        _campaignInfo = [NSMutableDictionary dictionary];
        
        for (NSDictionary *campaign in newInfo) {

            NSString *campaignId = [campaign[@"id"] stringValue];
            
            //  check is required, b/c status can be EXCLUDED as well
            NSString *status = [campaign[@"status"] uppercaseString];
            if ([status isEqualToString:@"EXCLUED"]) {
                // save 0 against experiment-id so that this user can be excluded from the experiment
                [[VAOModel sharedInstance] checkAndMakePartOfExperiment:campaignId variationId:@"0"];
                continue;
            } else if ([status isEqualToString:@"RUNNING"] == NO) {
                continue;
            } else if (![self hasValidValue:campaign[@"variations"]] || ![self hasValidValue:campaign[@"variations"][@"id"]]) {
                continue;
            }
            
            NSString *variationId = [NSString stringWithFormat:@"%@", campaign[@"variations"][@"id"]];
            NSMutableDictionary *campaignDict = [NSMutableDictionary dictionary];
            
            campaignDict[@"variationId"] = variationId;
            campaignDict[@"variationName"] = campaign[@"variations"][@"name"];
            campaignDict[@"goals"] = campaign[@"goals"];
            campaignDict[@"json"] = campaign[@"variations"][@"changes"];
            campaignDict[@"status"] = campaign[@"status"];

            if (campaign[@"segment_object"]) {
                campaignDict[@"segment"] = campaign[@"segment_object"];
            }
            
            if (campaign[@"UA"]) {
                campaignDict[@"UA"] = campaign[@"UA"];
            }
            
            campaignDict[@"name"] = (campaign[@"name"] ? campaign[@"name"] : @"VWO Campaign Name");
            
            // check if we can run this experiment on this user
            if ([self checkSegmentation:campaignId forCampaign:campaignDict]) {
                [_campaignInfo setObject:campaignDict forKey:campaignId];
                
                // count user in campaign
                if(_trackUserManually == NO) {
                    [self checkAndtrackUserForExperiment:campaignId forCampaign:campaignDict];
                }
            }
        }
        if (!_previewMode) {
            [[VAOModel sharedInstance] saveCampaignInfo:_campaignInfo];
        }
    } @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
}


-(BOOL)evaluateOperand:(NSArray*)operandValue lOperandValue:(NSString*)lOperandValue operator:(int)operator type:(SegmentationType)segmentType {
    
    // remove null values
    NSMutableArray *newoperandValue = [NSMutableArray arrayWithArray:operandValue];
    [newoperandValue removeObjectIdenticalTo:[NSNull null]];
    operandValue = newoperandValue;
    if (operandValue.count == 0) {
        return YES;
    }
    
    BOOL toReturn = NO;
    switch (segmentType) {
        case SegmentationTypeiOSVersion: {
            NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
            // consider only x.y version
            //TODO: fix this
            //Wont work since major version of the release now contain two digit numbers
            if (currentVersion.length > 3) {
                currentVersion = [currentVersion substringToIndex:3];
            } else if (currentVersion.length == 1) {
                currentVersion = [currentVersion stringByAppendingString:@".0"];
            }


            if ([operandValue containsObject:currentVersion]) {
                if (operator == 11) {
                    toReturn = YES;
                } else if (operator == 12) {
                    toReturn = NO;
                }
            } else {
                // iterate
                if (operator == 12) {
                    toReturn = YES;
                }

                for (NSString *version in operandValue) {
                    if (version && ([version rangeOfString:@">="].location != NSNotFound)) {
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO([version substringFromIndex:2])) {
                            if (operator == 11) {
                                toReturn = YES;
                            } else if (operator == 12) {
                                toReturn = NO;
                            }
                        }
                        break;
                    }
                }
            }
            break;
        }
        case SegmentationTypeDayOfWeek: {
            // day of week
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
            NSInteger weekday = [comps weekday];

            // start from sunday = 0
            weekday = weekday - 1;

            // set default to YES in case of NOT equal to
            if (operator == 12) {
                toReturn = YES;
            }

            if ([operandValue containsObject:[NSNumber numberWithInteger:weekday]]) {
                if (operator == 11) {
                    toReturn = YES;
                } else if (operator == 12) {
                    toReturn = NO;
                }
            }
            break;
        }
        case SegmentationTypeHourOfTheDay: {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *comps = [gregorian components:NSCalendarUnitHour fromDate:[NSDate date]];
            NSInteger hourOfDay = [comps hour];

            // set default to YES in case of NOT equal to
            if (operator == 12) {
                toReturn = YES;
            }

            if ([operandValue containsObject:[NSNumber numberWithInteger:hourOfDay]]) {
                if (operator == 11) {
                    toReturn = YES;
                } else if (operator == 12) {
                    toReturn = NO;
                }
            }
            break;
        }
        case SegmentationTypeLocation: {
            NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];

            // set default to YES in case of NOT equal to
            if (operator == 12) {
                toReturn = YES;
            }

            if (([operandValue containsObject:country])) {
                if (operator == 11) {
                    toReturn = YES;
                } else if (operator == 12) {
                    toReturn = NO;
                }
            }
            break;
        }
        case SegmentationTypeAppVersion: {
            // App Version
            NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
            NSString *currentVersion = infoDictionary[@"CFBundleShortVersionString"];
            NSString *targetVersion = [operandValue firstObject];
            switch (operator) {
                case 5: {
                    if([currentVersion rangeOfString:targetVersion options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) {
                        toReturn = YES;
                    }

                    break;
                }

                case 7: {  // Contains
                    if ([currentVersion rangeOfString:targetVersion].location != NSNotFound) {
                        toReturn = YES;
                    }
                    break;
                }

                case 11: {  // is equal to
                    if ([targetVersion isEqualToString:currentVersion]) {
                        toReturn = YES;
                    }
                    break;
                }

                case 12: {  // is NOT equal to
                    if ([targetVersion isEqualToString:currentVersion] == NO) {
                        toReturn = YES;
                    }
                    break;
                }

                case 13: {  // starts with
                    NSRange range =  [currentVersion rangeOfString:targetVersion];
                    if (range.location == 0) {
                        toReturn = YES;
                    }
                    
                    break;
                }
                default: break;
            }
            break;
        }
        case SegmentationTypeCustomVariable: {
            NSString *targetValue = [operandValue firstObject];
            NSString *currentValue = [customVariables objectForKey:lOperandValue];
            if (!currentValue) {
                toReturn = NO;
                return toReturn;
            }

            //        [nil range]
            switch (operator) {
                case 5: {
                    if([currentValue rangeOfString:targetValue options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) {
                        toReturn = YES;
                    }

                    break;
                }

                case 7: {  // Contains
                    if ([currentValue rangeOfString:targetValue].location != NSNotFound) {
                        toReturn = YES;
                    }
                    break;
                }

                case 11: {  // is equal to
                    if ([targetValue isEqualToString:currentValue]) {
                        toReturn = YES;
                    }
                    break;
                }

                case 12: {  // is NOT equal to
                    if ([targetValue isEqualToString:currentValue] == NO) {
                        toReturn = YES;
                    }
                    break;
                }

                case 13: {  // starts with
                    NSRange range =  [currentValue rangeOfString:targetValue];
                    if (range.location == 0) {
                        toReturn = YES;
                    }
                    
                    break;
                }
                default: break;
            }
            break;
        }
        default: break;
    }    
    return toReturn;
}

/**
 *  Return YES if user falls under the predefined segment,
 *         NO otherwise
 */
- (BOOL)evaluatePredefinedSegmentation:(NSDictionary*)segmentObject {
    
    if ([segmentObject[@"device"] isEqualToString:@"iPad"] &&
        ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        
        return YES;
        
    } else if ([segmentObject[@"device"] isEqualToString:@"iPhone"] &&
               ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)) {
        return YES;
    } else if (segmentObject[@"returning_visitor"]) {
        return ([VAOSDKInfo isReturningVisitor] == [segmentObject[@"returning_visitor"] boolValue]);
    }
    
    return NO;
}

/**
 *

 
 evaluate object as VAL
 
 if has operator and a left paranthesis
    push operator on stack
 else if has operator
	pop from stack and apply operator to VAL
 
 if left parenthesis
	push parenthesis on stack
 
 if right parenthesis
	pop stack (it should be left parenthesis)
    
    unless we find a left paranthesis OR stack is not empty
        keep popping and apply
 
 push VAL on stack
 
 */
- (BOOL)evaluateCustomSegmentation:(NSArray*)segmentObjects {
    
    NSMutableArray *stack = [NSMutableArray array];
    @try {

        for (NSDictionary *segment in segmentObjects) {
            BOOL leftParenthesis = [segment[@"lBracket"] boolValue];
            BOOL rightParenthesis = [segment[@"rBracket"] boolValue];
            int operator = [segment[@"operator"] intValue];
            NSString *logicalOperator = segment[@"prevLogicalOperator"];
            
            NSArray *operandValue;
            if ([segment[@"rOperandValue"] isKindOfClass:[NSArray class]]) {
                operandValue = segment[@"rOperandValue"];
            } else {
                operandValue = [NSArray arrayWithObject:segment[@"rOperandValue"]];
            }

            NSString *lOperandValue = segment[@"lOperandValue"];
            SegmentationType segmentType = [segment[@"type"] intValue];

            //1
            // evaluate
            BOOL currentValue = [self evaluateOperand:operandValue lOperandValue:lOperandValue operator:operator type:segmentType];
            
            //2
            if (logicalOperator && leftParenthesis) {
                [stack addObject:logicalOperator];
            } else if (logicalOperator) {
                BOOL leftVariable = [[stack lastObject] boolValue];
                [stack removeLastObject];
                
                // apply operator to these two
                if ([logicalOperator isEqualToString:@"AND"]) {
                    currentValue = (leftVariable && currentValue);
                } else {
                    currentValue = (leftVariable || currentValue);
                }
            }
            
            //3
            if (leftParenthesis) {
                [stack addObject:@"("];
            }
            
            //4
            if (rightParenthesis) {
                [stack removeLastObject];
                
                while ((stack.count > 0) && ![[stack lastObject] isEqualToString:@")"]) {
                    NSString *stackLogicalOperator = [stack lastObject];
                    [stack removeLastObject];
                    
                    BOOL leftVariable = [[stack lastObject] boolValue];
                    [stack removeLastObject];
                    
                    // apply operator to these two
                    if ([stackLogicalOperator isEqualToString:@"AND"]) {
                        currentValue = (leftVariable && currentValue);
                    } else {
                        currentValue = (leftVariable || currentValue);
                    }
                    
                }
            }
            
            [stack addObject:[NSNumber numberWithBool:currentValue]];
        }
    }
    @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
    @finally {
        return [[stack lastObject] boolValue];
    }
}

/**
 * This replaces the _meta with the passed in changes
 * In preview mode, we only provide the preview changes and do not provide meta of currently running experiments
 */
- (void)preview:(NSDictionary *)changes {

    // convert changes dictionary to our usable format
    NSString *experimentId = [NSString stringWithFormat:@"%i", arc4random()];
    NSString *variationId = [NSString stringWithFormat:@"%@", [changes objectForKey:@"variationId"]];
    _campaignInfo = [NSMutableDictionary dictionary];
    _campaignInfo[experimentId] = @{
                            @"variationId":variationId,
                            @"json":changes[@"json"]
                            };
}

#pragma mark Goal

- (void)markConversionForGoal:(NSString*)goal withValue:(NSNumber*)value {
    
    if (_previewMode) {
        [[VAOSocketClient sharedInstance] goalTriggeredWithName:goal];
        return;
    }

    // find for each experiment, whether goal is present or not
    for (NSString *expId in [_campaignInfo allKeys]) {
        
        // check if user is part of this experiment
        if ([[VAOModel sharedInstance] hasBeenPartOfExperiment:expId] == NO) {
            // user has not been part of this experiment, so no need to check and trigger goal
            continue;
        }
        
        NSDictionary *experiment = _campaignInfo[expId];
        NSString *variationId = [experiment valueForKey:@"variationId"];
        NSArray *goalsArray = [experiment objectForKey:@"goals"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", goal];
        
        NSArray *filteredGoalsArray = [goalsArray filteredArrayUsingPredicate:predicate];
        if (filteredGoalsArray.count == 0) {
            continue;
        }
        for (NSDictionary *goalDictionary in filteredGoalsArray) {
            // goal exists for this experiment
            
            NSInteger goalId = [goalDictionary[@"id"] integerValue];
            NSString *goalIdAsString = [NSString stringWithFormat:@"%li", (long)goalId];
            BOOL shouldTriggerGoal = [[VAOModel sharedInstance] shouldTriggerGoal:goalIdAsString forExperiment:expId];
            
            if (shouldTriggerGoal) {
                [[VAOAPIClient sharedInstance] pushGoalConversionWithGoalId:goalId
                                                               experimentId:[expId integerValue]
                                                                variationId:variationId
                                                                    revenue:value];
                
                if (experiment[@"UA"]) {
                    [[VAOGoogleAnalytics sharedInstance] goalTriggeredWithName:goal
                                                                        goalId:goalIdAsString
                                                                     goalValue:value
                                                                experimentName:experiment[@"name"]
                                                                  experimentId:expId
                                                                 variationName:experiment[@"variationName"]
                                                                   variationId:variationId];
                }
            }

        }
    }
}

- (id)variationForKey:(NSString*)key {
    NSMutableArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];

    for (VAOCampaign *campaign in campaignList) {
        id variation = [campaign variationForKey:key];
        if (variation) {
            //If campaign has key and `trackUserOnLaunch` is not enabled
            //then start tracking User and return the variation for key.
            if (!campaign.trackUserOnLaunch) {
                [[VAOModel sharedInstance] trackUserForCampaign:campaign];
            }
            return [variation copy];
        }
    }
    return nil;
}

- (void)trackUserInCampaign:(NSString*)key {
    if(_trackUserManually == NO) {
        return;
    }
    
    @try {
        for (NSString *expId in [_campaignInfo allKeys]) {
            NSDictionary *experiment = _campaignInfo[expId];
            
            if ([experiment[@"json"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *thisExpJSON = experiment[@"json"];
                if (thisExpJSON[key]) {
                    [self checkAndtrackUserForExperiment:expId forCampaign:experiment];
                    return;
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
}

/**
 *  This method verifies if user has been part of the experiment
 *  If YES (user has been part) it returns YES
 *  If NO
 *      It checks and applies segmentation.
 *      If user passes the segmentation it makes user part of the experiment and returns YES
 *      Otherwise returns NO
 *
 */
- (BOOL)checkSegmentation:(NSString*)expId forCampaign:(NSDictionary*)experiment {
    if ([[VAOModel sharedInstance] hasBeenPartOfExperiment:expId] == NO) {
        
        // check if segmentation exists
        if (experiment[@"segment"]) {
            
            // apply segmentation now
            BOOL evaluation = YES;
            if ([experiment[@"segment"][@"type"] isEqualToString:@"custom"]) {
                evaluation = [self evaluateCustomSegmentation:experiment[@"segment"][@"partialSegments"]];
            } else if([experiment[@"segment"][@"type"] isEqualToString:@"predefined"]) {
                evaluation = [self evaluatePredefinedSegmentation:experiment[@"segment"][@"segment_code"]];
            }
            
            //if user is not deemed for this experiment, then skip this experiment
            if (!evaluation) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)checkAndtrackUserForExperiment:(NSString*)expId forCampaign:(NSDictionary*)experiment {
    if ([[VAOModel sharedInstance] hasBeenPartOfExperiment:expId]) {
        return;
    }
    
    // make user part of this experiment
    [[VAOModel sharedInstance] checkAndMakePartOfExperiment:expId
                                                variationId:experiment[@"variationId"]];
    
    // if UA integration is enabled
    if (experiment[@"UA"]) {
        NSNumber *dimension = (experiment[@"UA"][@"s"] ? experiment[@"UA"][@"s"]: @1);
        [[VAOGoogleAnalytics sharedInstance] experimentWithName:experiment[@"name"]
                                                   experimentId:expId
                                                  variationName:(experiment[@"variationName"] ? experiment[@"variationName"] : @"variation-name")
                                                    variationId:experiment[@"variationId"]
                                                      dimension:dimension];
    }
}
@end
