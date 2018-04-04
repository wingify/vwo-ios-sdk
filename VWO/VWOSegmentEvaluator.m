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
#import "VWOSegment.h"
#import "VWOInfixEvaluator.h"

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

- (BOOL)canUserBePartOfCampaignForSegment:(NSDictionary *)segment {
    if (segment == nil) return YES;
    if ([segment[kType] isEqualToString:@"custom"]) {
        NSArray *partialSegments = (NSArray *)segment[kPartialSegments];
        return [self evaluateCustomSegmentation:partialSegments];
    } else if ([segment[kType] isEqualToString:@"predefined"]) {
        return [self evaluatePredefinedSegmentation:segment[kSegmentCode]];
    }
    return NO;
}

- (BOOL)evaluatePredefinedSegmentation:(NSDictionary *)segmentObject {
    NSAssert(self.appleDeviceType == VWOAppleDeviceTypeIPad ||
             self.appleDeviceType == VWOAppleDeviceTypeIPhone,
             @"Invalid Apple device type");

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
    NSMutableArray *infix = [NSMutableArray new];
    NSUInteger count = 0;
    for (NSDictionary *partialSegment in partialSegments) {
        VWOSegment *segment = [[VWOSegment alloc] initWithDictionary:partialSegment];
        if (segment) {
                //If first segment has previousLogicalOperator remove it.
            if (count == 0) { segment.previousLogicalOperator = VWOPreviousLogicalOperatorNone;}

            BOOL evaluated = [self evaluate:segment];
            NSArray *infixPart = [segment toInfixForOperand:evaluated];
            [infix addObjectsFromArray:infixPart];
            count++;
        }
    }
    return [VWOInfixEvaluator evaluate:infix];
}

- (BOOL)evaluate:(VWOSegment *) segment {

    if (segment.rOperand.count == 0) {
        return YES;
    }

    switch (segment.type) {
            case VWOSegmentTypeiOSVersion: {
                NSAssert(self.iOSVersion != nil, @"iOS Version not available");
                NSString *version = [self.iOSVersion version2Places];
                NSString *targetVersion = segment.rOperand.firstObject;
                NSComparisonResult result = [version compare:targetVersion options:NSNumericSearch];
                switch (segment.operator) {
                        case OperatorTypeIsEqualTo: return result == NSOrderedSame;
                        case OperatorTypeIsNotEqualTo: return result != NSOrderedSame;
                        case OperatorTypeGreaterThan: return result == NSOrderedDescending;
                        case OperatorTypeLessThan: return result == NSOrderedAscending;
                    default:
                        VWOLogException(@"Invalid operator received for iOSVersion %d", segment.operator);
                        return NO;
                }
                break;
            }

            case VWOSegmentTypeDayOfWeek: {
                NSAssert(self.date != nil, @"Date not available");
                BOOL contains = [segment.rOperand containsObject:[NSNumber numberWithInteger:self.date.dayOfWeek]];
                return ((contains && segment.operator == OperatorTypeIsEqualTo) ||
                        (!contains && segment.operator == OperatorTypeIsNotEqualTo));
            }

            case VWOSegmentTypeHourOfTheDay: {
                NSAssert(self.date != nil, @"Date not available");
                BOOL contains = [segment.rOperand containsObject:[NSNumber numberWithInteger:self.date.hourOfTheDay]];
                return ((contains && segment.operator == OperatorTypeIsEqualTo) ||
                        (!contains && segment.operator == OperatorTypeIsNotEqualTo));
            }

            case VWOSegmentTypeAppVersion: {
                NSAssert(_appVersion != nil, @"App Version not available");
                NSString *targetVersion = segment.rOperand.firstObject;
                VWOComparisonResult result = [_appVersion compareVersion:targetVersion];
                switch (segment.operator) {
                        case OperatorTypeIsEqualTo: return result == VWOComparisonResultEqual;
                        case OperatorTypeIsNotEqualTo: return result != VWOComparisonResultEqual;
                        case OperatorTypeGreaterThan: return result == VWOComparisonResultGreater;
                        case OperatorTypeLessThan: return result == VWOComparisonResultLesser;
                    default: return NO;
                }
                break;
            }

            case VWOSegmentTypeCustomVariable: {
                NSString *currentValue = [NSString stringWithFormat:@"%@", _customVariables[segment.lOperand]];
                if (currentValue == nil) return NO;

                NSString *targetValue = segment.rOperand.firstObject;
                switch (segment.operator) {
                        case OperatorTypeMatchesRegexCaseInsensitive:
                        return ([currentValue rangeOfString:targetValue
                                                    options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound);

                        case OperatorTypeContains:
                        return [currentValue rangeOfString:targetValue].location != NSNotFound;

                        case OperatorTypeIsEqualTo:
                        return [currentValue isEqualToString:targetValue];

                        case OperatorTypeIsNotEqualTo:
                        return ![currentValue isEqualToString:targetValue];

                        case OperatorTypeStartsWith:
                        return [currentValue hasPrefix:targetValue];

                    default:
                        return NO;
                }
                break;
            }

            case VWOSegmentTypeVisitorType: {
                NSString *givenType = segment.rOperand.firstObject;
                BOOL valid = (self.isReturning && [givenType isEqualToString:@"ret"]) ||
                (!self.isReturning && [givenType isEqualToString:@"new"]);
                return ((valid && segment.operator == OperatorTypeIsEqualTo) ||
                        (!valid && segment.operator == OperatorTypeIsNotEqualTo));
            }

            case VWOSegmentTypeDeviceType: {
                NSString *givenDeviceType = segment.rOperand.firstObject;
                BOOL valid = (self.appleDeviceType == VWOAppleDeviceTypeIPhone && [givenDeviceType isEqualToString:@"iPhone"]) ||
                (self.appleDeviceType == VWOAppleDeviceTypeIPad && [givenDeviceType isEqualToString:@"iPad"]);
                return ((valid && segment.operator == OperatorTypeIsEqualTo) ||
                        (!valid && segment.operator == OperatorTypeIsNotEqualTo));
            }

            case VWOSegmentTypeLocation: {
                NSString *countryCode = [self.locale objectForKey:NSLocaleCountryCode];
                if (countryCode == nil) { return NO;}
                BOOL contains = [segment.rOperand containsObject: countryCode];
                return ((contains && segment.operator == OperatorTypeIsEqualTo) ||
                        (!contains && segment.operator == OperatorTypeIsNotEqualTo));

            }
            case VWOSegmentTypeScreenWidth: {
                int targetWidth = [segment.rOperand.firstObject intValue];
                switch (segment.operator) {
                        case OperatorTypeIsEqualTo: return self.screenWidth == targetWidth;
                        case OperatorTypeIsNotEqualTo: return self.screenWidth != targetWidth;
                        case OperatorTypeGreaterThan: return self.screenWidth > targetWidth;
                        case OperatorTypeLessThan: return self.screenWidth < targetWidth;
                    default: return NO;
                }
            }
            case VWOSegmentTypeScreenHeight: {
                int targetHeight = [segment.rOperand.firstObject intValue];
                switch (segment.operator) {
                        case OperatorTypeIsEqualTo: return self.screenHeight == targetHeight;
                        case OperatorTypeIsNotEqualTo: return self.screenHeight != targetHeight;
                        case OperatorTypeGreaterThan: return self.screenHeight > targetHeight;
                        case OperatorTypeLessThan: return self.screenHeight < targetHeight;
                    default: return NO;
                }
            }

        default: return NO;
    }
}

@end
