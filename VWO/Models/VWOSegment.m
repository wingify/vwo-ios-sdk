//
//  VWOSegment.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import "VWOSegment.h"

@implementation VWOSegment

- (nullable instancetype)initWithDictionary:(NSDictionary *) segmentDict {
    self = [super init];
    if (self) {
        _operator = [segmentDict[@"operator"] intValue];

        // L-operand R- operand
        _lOperand = segmentDict[@"lOperandValue"];
        if ([segmentDict[@"rOperandValue"] isKindOfClass:[NSArray class]]) {
            _rOperand = segmentDict[@"rOperandValue"];
        } else {
            _rOperand = @[segmentDict[@"rOperandValue"]];
        }
        _type = [segmentDict[@"type"] intValue];

        //Previous logical operator
        NSString *operator = segmentDict[@"prevLogicalOperator"];
        if ([operator  isEqual: @"AND"]) {
            _previousLogicalOperator = VWOPreviousLogicalOperatorAnd;
        } else if ([operator  isEqual: @"OR"]) {
            _previousLogicalOperator = VWOPreviousLogicalOperatorOr;
        } else {
            _previousLogicalOperator = VWOPreviousLogicalOperatorNone;
        }

        //Brackets
        _leftBracket = [segmentDict[@"lBracket"] boolValue];
        _rightBracket = [segmentDict[@"rBracket"] boolValue];
    }
    return self;

}

- (NSArray *)toInfixForOperand:(BOOL)evaluatedOperand {
    NSMutableArray <NSString *>*arr = [NSMutableArray new];
    if (_previousLogicalOperator == VWOPreviousLogicalOperatorAnd) {
        [arr addObject:@"&"];
    } else if (_previousLogicalOperator == VWOPreviousLogicalOperatorOr) {
        [arr addObject:@"|"];
    }
    if (_leftBracket) {
        [arr addObject:@"("];
    }
    [arr addObject:evaluatedOperand ? @"1" : @"0"];
    if(_rightBracket) {
        [arr addObject:@")"];
    }
    return arr;
}

@end
