//
//  VWOSegment.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import "VWOSegment.h"

@implementation VWOSegment {
    BOOL leftBracket;
    BOOL rightBracket;
    NSString *previousLogicalOperator;
}

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

        previousLogicalOperator = segmentDict[@"prevLogicalOperator"];
        if ([previousLogicalOperator  isEqual: @"AND"]) {
            previousLogicalOperator = @"&";
        } else if ([previousLogicalOperator  isEqual: @"OR"]) {
            previousLogicalOperator = @"|";
        }
        leftBracket = [segmentDict[@"lBracket"] boolValue];
        rightBracket = [segmentDict[@"rBracket"] boolValue];
    }
    return self;

}

- (NSArray *)toInfixForOperand:(BOOL)evaluatedOperand {
    NSMutableArray *arr = [NSMutableArray new];
    if (previousLogicalOperator != nil) {
        [arr addObject:previousLogicalOperator];
    }
    if (leftBracket) {
        [arr addObject:@"("];
    }
    [arr addObject:evaluatedOperand ? @"1" : @"0"];
    if(rightBracket) {
        [arr addObject:@")"];
    }
    return arr;
}

@end
