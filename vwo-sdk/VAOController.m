//
//  VAOController.m
//  VAO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOController.h"
#import "VAOUtils.h"
#import "VAOModel.h"
#import "VAOAPIClient.h"
#import "VAOSocketClient.h"
#import "VAOGoogleAnalytics.h"
//#import "VAOFlurry.h"
#import "VAORavenClient.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static const NSTimeInterval kMinUpdateTimeGap = 60*60; // seconds in 1 hour

@implementation VAOController {
    
    BOOL _remoteDataDownloading;
    NSTimeInterval _lastUpdateTime;
    BOOL _previewMode;
    NSMutableDictionary *_meta; // holds the set of changes to be applied to various UI elements
    NSMutableDictionary *_activeGoals;
    NSMutableDictionary *customVariables;
}

+ (void)initializeAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    [[self sharedInstance] loadMetaList];
    [[self sharedInstance] downloadMetaAsynchronously:async withCallback:completionBlock];
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
        _activeGoals = [[NSMutableDictionary alloc] init];
        customVariables = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadMetaList {
    _meta = [[VAOModel sharedInstance] loadMeta];
}

- (void)setValue:(NSString*)value forCusomtorVariable:(NSString*)variable {
    if(!value || !variable) return;
    @try {
        [customVariables setObject:value forKey:variable];
    }
    @catch (NSException *exception) {
        VAORavenCaptureException(exception);
    }
    @finally {
        
    }
}

- (void)applicationDidEnterBackground {
    if(_previewMode == NO) {
        _lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
        [[VAOAPIClient sharedInstance] applicationDidEnterBackground];
    }
}

- (void)applicationWillEnterForeground {
    [[VAOAPIClient sharedInstance] applicationWillEnterForeground];
    if(_remoteDataDownloading == NO) {
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        if(currentTime - _lastUpdateTime < kMinUpdateTimeGap){
            return;
        }
        
        [self downloadMetaAsynchronously:YES withCallback:nil];
    }
}


- (void)downloadMetaAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    _remoteDataDownloading = YES;
    
    [[VAOModel sharedInstance] downloadMetaWithCompletionBlock:^(NSMutableArray *meta){
        _lastUpdateTime = currentTime;
        _remoteDataDownloading = NO;
        
        [self _useMeta:meta];
        if (completionBlock) {
            completionBlock();
        }
    } withCurrentMeta:[[VAOModel sharedInstance] getCurrentExperimentsVariationPairs] asynchronously:async];
}

- (void)applicationDidEnterPreviewMode {
    _previewMode = YES;
    [[VAOAPIClient sharedInstance] applicationDidEnterPreviewMode];
}

- (void)applicationDidExitPreviewMode{
    _previewMode = NO;
    [[VAOAPIClient sharedInstance] applicationDidExitPreviewMode];
    
    // we should load
    [self loadMetaList];
}

/**
 *  Sample Meta Structure
{
    "1": {
        "variationId": 123,
        "goals": [
             {
                 "type": "REVENUE_TRACKING",
                 "identifier": "Banner Track",
                 "id": 1
             }
        ],
        "json": {
            "What": "VWO Json Experiemnt",
            "value": 184467440737095500000
        },
         "segment": {
            "segmentationType": "pre",
             "segment_code": {
                "device": "iPad"
             },
             "id": "some-id",
             "type": "predefined",
             "name": "iPad Traffic",
             "platform": "mobile-app",
             "description": "Segment for iPad traffic only"
         }
    },
    "2": {
        "variationId": 1231,
        "goals": [
             {
             "type": "REVENUE_TRACKING",
             "identifier": "Banner Track",
             "id": 1
             }
        ],
        "json": {
            "reaction": "WOW"
        }
    }
}
 */

/**
 *  returns NO if value is nil or [NSNull null]
 */
- (BOOL)isValueValid:(id)value {
    if (value == nil) {
        return NO;
    }
    
    if (value == [NSNull null]) {
        return NO;
    }
    
    return YES;
}

/**
 *  Rewrite meta file.
 */
- (void)_useMeta:(NSMutableArray *)newMeta{
//    VAOLog(@"Meta before: %@", [_meta description]);

    @try {        
        _meta = [NSMutableDictionary dictionary];
        
        for (NSDictionary *experiment in newMeta) {
            
            NSString *experimentId = [experiment[@"id"] stringValue];
            
            /**
             *  check is required, b/c status can be EXCLUDED as well
             */
            NSString *status = [experiment[@"status"] uppercaseString];
            if ([status isEqualToString:@"EXCLUED"]) {
                // save 0 against experiment-id so that this user can be excluded from the experiment
                [[VAOModel sharedInstance] checkAndMakePartOfExperiment:experimentId variationId:@"0"];
                continue;
            } else if ([status isEqualToString:@"RUNNING"] == NO) {
                continue;
            } else if (![self isValueValid:experiment[@"variations"]] || ![self isValueValid:experiment[@"variations"][@"id"]]) {
                continue;
            }
            
            NSString *variationId = [NSString stringWithFormat:@"%@", experiment[@"variations"][@"id"]];
            NSMutableDictionary *experimentDict = [NSMutableDictionary dictionary];
            
            experimentDict[@"variationId"] = variationId;
            experimentDict[@"variationName"] = experiment[@"variations"][@"name"];
            experimentDict[@"goals"] = experiment[@"goals"];
            experimentDict[@"json"] = experiment[@"variations"][@"changes"];
            experimentDict[@"status"] = experiment[@"status"];
            if ([experiment[@"count_goal_once"] boolValue]) {
                [experimentDict setValue:@1 forKey:@"countGoalOnce"];
            } else {
                [experimentDict setValue:@0 forKey:@"countGoalOnce"];
            }
            
            if (experiment[@"segment_object"]) {
                experimentDict[@"segment"] = experiment[@"segment_object"];
            }
            
            if (experiment[@"UA"]) {
                experimentDict[@"UA"] = experiment[@"UA"];
            }
            
            experimentDict[@"name"] = (experiment[@"name"] ? experiment[@"name"] : @"VWO Campaign Name");
            
            // check if we can run this experiment on this user
            if ([self checkSegmentationAndMakePartOfExperiment:experimentId forExperiment:experimentDict]) {
                [_meta setObject:experimentDict forKey:experimentId];
            }
        }
        
        //    VAOLog(@"Meta after: %@", [_meta description]);
        
        if (!_previewMode) {
            [[VAOModel sharedInstance] saveMeta:_meta];
        }
    } @catch (NSException *exception) {
        NSException *selfException = [[NSException alloc] initWithName:NSStringFromSelector(_cmd) reason:[exception description] userInfo:exception.userInfo];
        VAORavenCaptureException(selfException);
        VAORavenCaptureException(exception);
    } @finally {
        
    }

    
}

/**
 * https://github.com/fahrulazmi/UIDeviceHardware/blob/master/UIDeviceHardware.m
 */

- (NSString *)platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}


-(BOOL)evaluateOperand:(NSArray*)operandValue lOperandValue:(NSString*)lOperandValue operator:(int)operator type:(int)type {
    
    // remove null values
    NSMutableArray *newoperandValue = [NSMutableArray arrayWithArray:operandValue];
    [newoperandValue removeObjectIdenticalTo:[NSNull null]];
    operandValue = newoperandValue;
    if (operandValue.count == 0) {
        return YES;
    }
    
    BOOL toReturn = NO;
    if (type == 1) {
        // ios version type
        
        // find current version
        NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
        // consider only x.y version
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
        
    } else if (type == 2) {
        // device type
        
        if(TARGET_IPHONE_SIMULATOR) {
            toReturn = YES;
        } else {
            NSString *platform = [self platform];
            
            // set default to YES in case of NOT equal to
            if (operator == 12) {
                toReturn = YES;
            }
            
            if ([operandValue containsObject:platform]) {
                if (operator == 11) {
                    toReturn = YES;
                } else if (operator == 12) {
                    toReturn = NO;
                }
            }
        }
    } else if (type ==3) {
        // day of week
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
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
        
    } else if (type == 4) {
        // hour of the day
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:NSHourCalendarUnit fromDate:[NSDate date]];
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
        
    } else if (type == 5) {
        // Country
        
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
        
    } else if (type == 6) {
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
            default:
                break;
        }
    } else if (type == 7) {
        // Custom Variable
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
            default:
                break;
        }
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
        return ([VAOUtils getIsNewVisitor] != [segmentObject[@"returning_visitor"] boolValue]);
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
            int type = [segment[@"type"] intValue];
            
            //1
            // evaluate
            BOOL currentValue = [self evaluateOperand:operandValue lOperandValue:lOperandValue operator:operator type:type];
            
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
        NSException *selfException = [[NSException alloc] initWithName:NSStringFromSelector(_cmd) reason:[exception description] userInfo:exception.userInfo];
        VAORavenCaptureException(selfException);
        VAORavenCaptureException(exception);
    }
    @finally {
        return [[stack lastObject] boolValue];
    }
}

/**
 * This replaces the _meta with the passed in changes
 * In preview mode, we only provide the preview changes and do not provide meta of currently running experiments
 */
- (void)previewMeta:(NSDictionary *)changes {

    // convert changes dictionary to our usable format
    NSString *experimentId = [NSString stringWithFormat:@"%i", arc4random()];
    NSString *variationId = [NSString stringWithFormat:@"%@", [changes objectForKey:@"variationId"]];
    _meta = [NSMutableDictionary dictionary];
    _meta[experimentId] = @{
                            @"variationId":variationId,
                            @"json":changes[@"json"]
                            };
}

#pragma mark Goal

- (void)markConversionForGoal:(NSString*)goal withValue:(NSNumber*)value {
    
    if (!goal) {
        NSLog(@"VWO: Please provide a valid goal");
    }
    
    if (_previewMode) {
        [[VAOSocketClient sharedInstance] goalTriggeredWithName:goal];
        return;
    }

    // find for each experiment, whether goal is present or not
    for (NSString *expId in [_meta allKeys]) {
        
        // check if user is part of this experiment
        if ([[VAOModel sharedInstance] hasBeenPartOfExperiment:expId] == NO) {
            // user has not been part of this experiment, so no need to check and trigger goal
            continue;
        }
        
        NSDictionary *experiment = _meta[expId];
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
            BOOL triggerGoalOnce = [experiment[@"countGoalOnce"] boolValue];
            BOOL shouldTriggerGoal = (triggerGoalOnce ? [[VAOModel sharedInstance] shouldTriggerGoal:goalIdAsString forExperiment:expId]  : YES);
            
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
                //push to snowplow
                //                [[VAODataCollector sharedInstance] trackGoalWithExperimentId:[expId intValue]
                //                                                                 variationId:[variationId intValue]
                //                                                                    goalName:goal
                //                                                                     revenue:nil];
            }

        }
    }
}


- (id)objectForKey:(NSString*)key {
    @try {
        for (NSString *expId in [_meta allKeys]) {
            NSDictionary *experiment = _meta[expId];
            
            if ([experiment[@"json"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *thisExpJSON = experiment[@"json"];
                if (thisExpJSON[key]) {
                    return [thisExpJSON[key] copy];
                }
            }
            
        }
        return nil;
    }
    @catch (NSException *exception) {
        NSException *selfException = [[NSException alloc] initWithName:NSStringFromSelector(_cmd) reason:[exception description] userInfo:exception.userInfo];
        VAORavenCaptureException(selfException);
        VAORavenCaptureException(exception);
    }
    @finally {
        
    }
}

- (id)allObjects {
    @try {
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        for (NSString *expId in [_meta allKeys]) {
            NSDictionary *experiment = _meta[expId];
            
            if ([experiment[@"json"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *thisExpJSON = experiment[@"json"];
                [json addEntriesFromDictionary:[thisExpJSON copy]];
            }

        }
        return json;
    }
    @catch (NSException *exception) {
        NSException *selfException = [[NSException alloc] initWithName:NSStringFromSelector(_cmd) reason:[exception description] userInfo:exception.userInfo];
        VAORavenCaptureException(selfException);
        VAORavenCaptureException(exception);
    }
    @finally {
        
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
- (BOOL)checkSegmentationAndMakePartOfExperiment:(NSString*)expId forExperiment:(NSDictionary*)experiment {
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
    
    return YES;
}

@end

