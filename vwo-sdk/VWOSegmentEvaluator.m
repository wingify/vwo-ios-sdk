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
#import "NSCalendar+VWO.h"
#import "VAODeviceInfo.h"

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
    if (!segment) return YES;
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

+ (BOOL)evaluateCustomSegmentation:(NSArray*)partialSegments {

    NSMutableArray *stack = [NSMutableArray array];
    for (NSDictionary *partialSegment in partialSegments) {
        BOOL leftParenthesis = [partialSegment[@"lBracket"] boolValue];
        BOOL rightParenthesis = [partialSegment[@"rBracket"] boolValue];
        int operator = [partialSegment[@"operator"] intValue];
        NSString *logicalOperator = partialSegment[@"prevLogicalOperator"];

        NSArray *operandValue;
        if ([partialSegment[@"rOperandValue"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *newoperandValue = partialSegment[@"rOperandValue"];
            [newoperandValue removeObjectIdenticalTo:[NSNull null]];
            operandValue = newoperandValue;
        } else {
            operandValue = [NSArray arrayWithObject:partialSegment[@"rOperandValue"]];
        }

        NSString *lOperandValue = partialSegment[@"lOperandValue"];
        SegmentationType segmentType = [partialSegment[@"type"] intValue];

        BOOL currentValue = [self evaluateSegmentForOperand:operandValue lOperand:lOperandValue operator:operator type:segmentType];

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
    return [[stack lastObject] boolValue];
}

+(BOOL)evaluateSegmentForOperand:(NSArray *)operand
                        lOperand:(NSString *)lOperand
                        operator:(int)operator
                            type:(SegmentationType)segmentType {

    if (operand.count == 0) {
        return YES;
    }

    switch (segmentType) {
        case SegmentationTypeiOSVersion: {
            NSString *version = [VAODeviceInfo iOSVersionMinor:YES patch:NO];

            // Equal or greater
            if ([operand.lastObject hasPrefix:@">="] && [operand.lastObject hasSuffix:version]) {
                BOOL greaterOrEqual = NO;
                greaterOrEqual = ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending);
                return ((greaterOrEqual && operator == OperatorTypeIsEqualTo ) ||
                        (!greaterOrEqual && operator == OperatorTypeIsNotEqualTo));
            }
            BOOL contains = [operand containsObject:version];
            return ((contains && operator == OperatorTypeIsEqualTo ) ||
                    (!contains && operator == OperatorTypeIsNotEqualTo));
        }

        case SegmentationTypeDayOfWeek: {
            NSInteger currentDayOfWeek = [NSCalendar dayOfWeek];
            BOOL contains = [operand containsObject:[NSNumber numberWithInteger:currentDayOfWeek]];

            return ((contains && operator == OperatorTypeIsEqualTo) ||
                    (!contains && operator == OperatorTypeIsNotEqualTo));
        }

        case SegmentationTypeHourOfTheDay: {
            NSInteger hourOfTheDay = [NSCalendar hourOfTheDay];
            BOOL contains = [operand containsObject:[NSNumber numberWithInteger:hourOfTheDay]];

            return ((contains && operator == OperatorTypeIsEqualTo) ||
                    (!contains && operator == OperatorTypeIsNotEqualTo));
        }

        case SegmentationTypeLocation: {
            NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
            BOOL contains = [operand containsObject:country];

            return ((contains && operator == OperatorTypeIsEqualTo) ||
                    (!contains && operator == OperatorTypeIsNotEqualTo));
        }

        case SegmentationTypeAppVersion: {
            NSString *currentVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
            NSString *targetVersion = [operand firstObject];
            switch (operator) {
                case OperatorTypeMatchesRegexCaseInsensitive:
                    return ([currentVersion rangeOfString:targetVersion options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound);

                case OperatorTypeContains:
                    return [currentVersion rangeOfString:targetVersion].location != NSNotFound;

                case OperatorTypeIsEqualTo:
                    return [targetVersion isEqualToString:currentVersion];

                case OperatorTypeIsNotEqualTo:
                    return ![targetVersion isEqualToString:currentVersion];

                case OperatorTypeStartsWith:
                    return [currentVersion hasPrefix:targetVersion];

                default:
                    NSLog(@"Invalid operator received for AppVersion");
                    return NO;
            }
            break;
        }

        case SegmentationTypeCustomVariable: {
            NSString *currentValue = VAOModel.sharedInstance.customVariables[lOperand];
            if (!currentValue) return NO;

            NSString *targetValue = [operand firstObject];
            switch (operator) {
                case OperatorTypeMatchesRegexCaseInsensitive:
                    return ([currentValue rangeOfString:targetValue options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound);

                case OperatorTypeContains:
                    return [currentValue rangeOfString:targetValue].location != NSNotFound;

                case OperatorTypeIsEqualTo:
                    return [currentValue isEqualToString:targetValue];

                case OperatorTypeIsNotEqualTo:
                    return ![currentValue isEqualToString:targetValue];

                case OperatorTypeStartsWith:
                    return [currentValue hasPrefix:targetValue];

                default:
                    NSLog(@"Invalid operator received for Custom Variable");
                    return NO;
            }
            break;
        }
        default:
            NSLog(@"Invalid segment received %ld", (long)segmentType);
            return NO;
    }
}

@end
