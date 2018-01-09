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
    NSAssert(self.appleDeviceType == VWOAppleDeviceTypeIPad || self.appleDeviceType == VWOAppleDeviceTypeIPhone, @"Invalid Apple device type");
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

        //If first segment has previousLogicalOperator remove it.
        if (count == 0) { segment.previousLogicalOperator = nil;}

        BOOL evaluated = [self evaluate:segment];
        NSArray *infixPart = [segment toInfixForOperand:evaluated];
        [infix addObjectsFromArray:infixPart];
        count++;
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
            NSString *version = [self.iOSVersion toXDotY];
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
            switch (segment.operator) {
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
                    VWOLogException(@"Invalid operator received for AppVersion %d", segment.operator);
                    return NO;
            }
            break;
        }

        case VWOSegmentTypeCustomVariable: {
            NSString *currentValue = _customVariables[segment.lOperand];
            if (currentValue == nil) return NO;

            NSString *targetValue = segment.rOperand.firstObject;
            switch (segment.operator) {
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
                    VWOLogException(@"Invalid operator received for Custom Variable %d", segment.operator);
                    return NO;
            }
            break;
        }
        default:
            VWOLogException(@"Invalid segment received %ld", (long)segment.type);
            return NO;
    }
}

@end
