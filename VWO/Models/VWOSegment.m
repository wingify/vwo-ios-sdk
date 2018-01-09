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

        _lOperand = segmentDict[@"lOperandValue"];

        if ([segmentDict[@"rOperandValue"] isKindOfClass:[NSArray class]]) {
            _rOperand = segmentDict[@"rOperandValue"];
        } else {
            _rOperand = @[segmentDict[@"rOperandValue"]];
        }
        _type = [segmentDict[@"type"] intValue];

        _previousLogicalOperator = segmentDict[@"prevLogicalOperator"];
        if ([_previousLogicalOperator  isEqual: @"AND"]) {
            _previousLogicalOperator = @"&";
        } else if ([_previousLogicalOperator  isEqual: @"OR"]) {
            _previousLogicalOperator = @"|";
        }
        _leftBracket = [segmentDict[@"lBracket"] boolValue];
        _rightBracket = [segmentDict[@"rBracket"] boolValue];
    }
    return self;

}

- (NSArray *)toInfixForOperand:(BOOL)evaluatedOperand {
    NSMutableArray *arr = [NSMutableArray new];
    if (_previousLogicalOperator != nil) {
        [arr addObject:_previousLogicalOperator];
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
