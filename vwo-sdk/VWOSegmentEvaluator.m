//
//  VWOSegmentEvaluator.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 30/06/17.
//
//

#import "VWOSegmentEvaluator.h"
#import <UIKit/UIKit.h>
#import "VAORavenClient.h"
#import "VAOSDKInfo.h"
#import "VAOPersistantStore.h"
#import "VAOModel.h"

typedef NS_ENUM(NSInteger, SegmentationType) {
    SegmentationTypeCustomVariable=7,
    SegmentationTypeAppVersion=6,
    SegmentationTypeiOSVersion=1,
    SegmentationTypeDayOfWeek=3,
    SegmentationTypeHourOfTheDay=4,
    SegmentationTypeLocation=5
};

typedef NS_ENUM(NSInteger, OperatorType) {
    OperatorTypeIsEqualToCaseInsensitive    = 1,
    OperatorTypeIsNotEqualToCaseInsensitive = 2,
    OperatorTypeIsEqualToCaseSensitive      = 3,
    OperatorTypeIsNotEqualToCaseSensitive   = 4,
    OperatorTypeMatchesRegexCaseInsensitive = 5,
    OperatorTypeMatchesRegexCaseSensitive   = 6,
    OperatorTypeContains                    = 7,
    OperatorTypeDoesNotContain              = 8,
    OperatorTypeIsBlank                     = 9,
    OperatorTypeIsNotBlank                  = 10,
    OperatorTypeIsEqualTo                   = 11,
    OperatorTypeIsNotEqualTo                = 12,
    OperatorTypeStartsWith                  = 13,
    OperatorTypeEndsWith                    = 14,
    OperatorTypeGreaterThan                 = 15,
    OperatorTypeLessThan                    = 16,
    OperatorTypeConverted                   = 17,
    OperatorTypeNotConverted                = 18,
};

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static NSString * kType = @"type";
static NSString * kPartialSegments = @"partialSegments";
static NSString * kSegmentCode = @"segment_code";
static NSString * kDevice = @"device";
static NSString * kReturningVisitor = @"returning_visitor";

@implementation VWOSegmentEvaluator

+ (BOOL)canUserBePartOfCampaignForSegment:(NSDictionary *) segment {
    if ([segment[kType] isEqualToString:@"custom"]) {
        NSArray *partialSegments = (NSArray *)segment[kPartialSegments];
        return [self evaluateCustomSegmentation:partialSegments];
    } else if ([segment[kType] isEqualToString:@"predefined"]) {
        return [self evaluatePredefinedSegmentation:segment[kSegmentCode]];
    }
    return YES;
}

+ (BOOL)evaluatePredefinedSegmentation:(NSDictionary*)segmentObject {
    if ([segmentObject[kDevice] isEqualToString:@"iPad"] &&
        ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        return YES;
    } else if ([segmentObject[kDevice] isEqualToString:@"iPhone"] &&
               ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)) {
        return YES;
    } else if (segmentObject[kReturningVisitor]) {
        return ([VAOPersistantStore returningUser] == [segmentObject[kReturningVisitor] boolValue]);
    }
    return NO;
}

+ (BOOL)evaluateCustomSegmentation:(NSArray*)segmentObjects {

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

            //TODO: Custom Variables not supported yet.
            BOOL currentValue = [self evaluateSegmentForOperand:operandValue lOperand:lOperandValue operator:operator customVariables:nil type:segmentType];

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

            if (leftParenthesis) {
                [stack addObject:@"("];
            }

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
    }
    @finally {
        return [[stack lastObject] boolValue];
    }
}


+(BOOL)evaluateSegmentForOperand:(NSArray *)operand
                        lOperand:(NSString *)lOperand
                        operator:(int)operator
                 customVariables:(NSDictionary *)customVariables
                            type:(SegmentationType)segmentType {

    // remove null values
    NSMutableArray *newoperandValue = [NSMutableArray arrayWithArray:operand];
    [newoperandValue removeObjectIdenticalTo:[NSNull null]];
    operand = newoperandValue;
    if (operand.count == 0) {
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


            if ([operand containsObject:currentVersion]) {
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

                for (NSString *version in operand) {
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

            if ([operand containsObject:[NSNumber numberWithInteger:weekday]]) {
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

            if ([operand containsObject:[NSNumber numberWithInteger:hourOfDay]]) {
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

            if (([operand containsObject:country])) {
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
            NSString *targetVersion = [operand firstObject];
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
            NSString *targetValue = [operand firstObject];
            NSString *currentValue = VAOModel.sharedInstance.customVariables[lOperand];
            if (!currentValue) return NO;

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

@end
