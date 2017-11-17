//
//  VWOSegmentEvaluator.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 30/06/17.
//
//

#import "VWOSegmentEvaluator.h"
#import "VWODevice.h"
#import "VWOLogger.h"
#import "NSDate+VWO.h"
#import "NSString+VWO.h"

typedef NS_ENUM(NSInteger, SegmentationType) {
    SegmentationTypeCustomVariable = 7,
    SegmentationTypeAppVersion     = 6,
    SegmentationTypeiOSVersion     = 1,
    SegmentationTypeDayOfWeek      = 3,
    SegmentationTypeHourOfTheDay   = 4,
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

static NSString * kType             = @"type";
static NSString * kPartialSegments  = @"partialSegments";
static NSString * kSegmentCode      = @"segment_code";
static NSString * kDevice           = @"device";
static NSString * kReturningVisitor = @"returning_visitor";

@implementation VWOSegmentEvaluator

- (instancetype)initWithiOSVersion:(NSString *)iOSVersion
                        appVersion:(NSString *)appVersion
                              date:(NSDate *)date
                       isReturning:(BOOL)isReturning
                     appDeviceType:(VWOAppleDeviceType)deviceType
                   customVariables:(NSDictionary *)customVariables {

    self = [super init];
    if (self) {
        self.iOSVersion = iOSVersion;
        self.appVersion = appVersion;
        self.date = date;
        self.isReturning = isReturning;
        self.appleDeviceType = deviceType;
        self.customVariables = customVariables;
    }
    return self;
}

- (BOOL)canUserBePartOfCampaignForSegment:(NSDictionary *) segment {
    if (segment == nil) return YES;
    if ([segment[kType] isEqualToString:@"custom"]) {
        NSArray *partialSegments = (NSArray *)segment[kPartialSegments];
        return [self evaluateCustomSegmentation:partialSegments];
    } else if ([segment[kType] isEqualToString:@"predefined"]) {
        return [self evaluatePredefinedSegmentation:segment[kSegmentCode]];
    }
    return YES;
}

- (BOOL)evaluatePredefinedSegmentation:(NSDictionary *)segmentObject {
    if ([segmentObject[kDevice] isEqualToString:@"iPad"] &&
        (self.appleDeviceType == VWOAppleDeviceTypeIPad)) {
        return YES;
    } else if ([segmentObject[kDevice] isEqualToString:@"iPhone"] &&
               (self.appleDeviceType == VWOAppleDeviceTypeIPhone)) {
        return YES;
    } else if (segmentObject[kReturningVisitor]) {
        return (self.isReturning == [segmentObject[kReturningVisitor] boolValue]);
    }
    return NO;
}

- (BOOL)evaluateCustomSegmentation:(NSArray *)partialSegments {

    NSMutableArray *stack = [NSMutableArray array];
    for (NSDictionary *partialSegment in partialSegments) {
        BOOL leftParenthesis = [partialSegment[@"lBracket"] boolValue];
        BOOL rightParenthesis = [partialSegment[@"rBracket"] boolValue];
        int operator = [partialSegment[@"operator"] intValue];
        NSString *logicalOperator = partialSegment[@"prevLogicalOperator"];

        NSArray *operandValue;
        if ([partialSegment[@"rOperandValue"] isKindOfClass:[NSArray class]]) {
            operandValue = partialSegment[@"rOperandValue"];
        } else {
            operandValue = [NSArray arrayWithObject:partialSegment[@"rOperandValue"]];
        }

        NSString *lOperandValue = partialSegment[@"lOperandValue"];
        SegmentationType segmentType = [partialSegment[@"type"] intValue];

        BOOL currentValue = [self evaluateSegmentForOperand:operandValue lOperand:lOperandValue operator:operator type:segmentType];

        if (logicalOperator && leftParenthesis) {
            [stack addObject:logicalOperator];
        } else if (logicalOperator) {
            BOOL leftVariable = [stack.lastObject boolValue];
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

            while ((stack.count > 0) && ![stack.lastObject isEqualToString:@")"]) {
                NSString *stackLogicalOperator = stack.lastObject;
                [stack removeLastObject];

                BOOL leftVariable = [stack.lastObject boolValue];
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
    return [stack.lastObject boolValue];
}

- (BOOL)evaluateSegmentForOperand:(NSArray *)operand
                        lOperand:(NSString *)lOperand
                        operator:(int)operator
                            type:(SegmentationType)segmentType {

    if (operand.count == 0) {
        return YES;
    }

    switch (segmentType) {
        case SegmentationTypeiOSVersion: {
            NSString *version = [self.iOSVersion toXDotY];
            NSString *targetVersion = operand.firstObject;
            NSComparisonResult result = [version compare:targetVersion options:NSNumericSearch];
            switch (operator) {
                case OperatorTypeIsEqualTo: return result == NSOrderedSame;
                case OperatorTypeIsNotEqualTo: return result != NSOrderedSame;
                case OperatorTypeGreaterThan: return result == NSOrderedDescending;
                case OperatorTypeLessThan: return result == NSOrderedAscending;
                default:
                    VWOLogException(@"Invalid operator received for iOSVersion %d", operator);
                    return NO;
            }
            break;
        }

        case SegmentationTypeDayOfWeek: {
            BOOL contains = [operand containsObject:[NSNumber numberWithInteger:self.date.dayOfWeek]];
            return ((contains && operator == OperatorTypeIsEqualTo) ||
                    (!contains && operator == OperatorTypeIsNotEqualTo));
        }

        case SegmentationTypeHourOfTheDay: {
            BOOL contains = [operand containsObject:[NSNumber numberWithInteger:self.date.hourOfTheDay]];
            return ((contains && operator == OperatorTypeIsEqualTo) ||
                    (!contains && operator == OperatorTypeIsNotEqualTo));
        }

        case SegmentationTypeAppVersion: {
            NSString *targetVersion = operand.firstObject;
            switch (operator) {
                case OperatorTypeMatchesRegexCaseInsensitive:
                    return ([_appVersion rangeOfString:targetVersion options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound);

                case OperatorTypeContains:
                    return [_appVersion rangeOfString:targetVersion].location != NSNotFound;

                case OperatorTypeIsEqualTo:
                    return [targetVersion isEqualToString:_appVersion];

                case OperatorTypeIsNotEqualTo:
                    return ![targetVersion isEqualToString:_appVersion];

                case OperatorTypeStartsWith:
                    return [_appVersion hasPrefix:targetVersion];

                default:
                    VWOLogException(@"Invalid operator received for AppVersion %d", operator);
                    return NO;
            }
            break;
        }

        case SegmentationTypeCustomVariable: {
            NSString *currentValue = _customVariables[lOperand];
            if (!currentValue) return NO;

            NSString *targetValue = operand.firstObject;
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
                    VWOLogException(@"Invalid operator received for Custom Variable %d", operator);
                    return NO;
            }
            break;
        }
        default:
            VWOLogException(@"Invalid segment received %ld", (long)segmentType);
            return NO;
    }
}

@end
