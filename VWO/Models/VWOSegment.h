//
//  VWOSegment.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VWOSegmentType) {
    VWOSegmentTypeCustomVariable = 7,
    VWOSegmentTypeAppVersion     = 6,
    VWOSegmentTypeiOSVersion     = 1,
    VWOSegmentTypeDayOfWeek      = 3,
    VWOSegmentTypeHourOfTheDay   = 4,
    VWOSegmentTypeVisitorType    = 8,
    VWOSegmentTypeDeviceType     = 9,
    VWOSegmentTypeLocation       = 5,
    VWOSegmentTypeScreenWidth    = 10,
    VWOSegmentTypeScreenHeight   = 11
};

typedef NS_ENUM(NSInteger, VWOPreviousLogicalOperator) {
    VWOPreviousLogicalOperatorNone = 0,
    VWOPreviousLogicalOperatorAnd = 1,
    VWOPreviousLogicalOperatorOr = 2
};

@interface VWOSegment : NSObject

@property (nonatomic, assign) int operator;
@property NSString *lOperand;
@property NSArray *rOperand;
@property (nonatomic, assign) VWOSegmentType type;
@property (nonatomic, assign) BOOL leftBracket;
@property (nonatomic, assign) BOOL rightBracket;
@property (nonatomic, assign) VWOPreviousLogicalOperator previousLogicalOperator;

- (nullable instancetype)initWithDictionary:(NSDictionary *)segmentDict;

- (NSArray <NSString *>*)toInfixForOperand:(BOOL)evaluatedOperand;
@end

NS_ASSUME_NONNULL_END
