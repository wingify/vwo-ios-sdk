//
//  VWOInfixEvaluator.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import "VWOInfixEvaluator.h"
#import "VWOStack.h"

@implementation VWOInfixEvaluator {
    VWOStack *_operandStack;//Bool array
    VWOStack *_operatorStack;//NSString array
    NSArray *_expression;
}

static NSString *or = @"OR";
static NSString *and = @"AND";
static NSString *openBracket = @"(";
static NSString *closeBracket = @")";

- (instancetype)initWithExpression:(NSArray *) expression {
    if (self = [super init]) {
        _operandStack = [VWOStack new];
        _operatorStack = [VWOStack new];
        _expression = expression;
    }
    return self;
}

- (void) pushOperator:(NSString *)operator {
    [_operatorStack push:operator];
}

- (void)pushOperand:(BOOL) operand {
    [_operandStack push:@(operand)];
}

- (BOOL)evaluteOperator:(NSString *)operator forLHS:(BOOL)lhs RHS:(BOOL)rhs {
    if ([operator  isEqual: @"&"]) {
        return lhs && rhs;
    } else if([operator  isEqual: @"|"]) {
        return lhs || rhs;
    }
    return NO;
}

- (void)evaluateStack {
    if (_operatorStack.isEmpty) {
        return;
    }

    if ([_operatorStack.peek isEqualToString:@"("]) {
        [_operatorStack pop];
        return;
    }
    NSString *a;
    while ( ![a isEqualToString:@"("] && !_operandStack.isEmpty) {
        NSString *operator = _operatorStack.pop;
        BOOL rhs = _operandStack.pop;
        BOOL lhs = _operandStack.pop;
        BOOL answer = [self evaluteOperator:operator forLHS:lhs RHS:rhs];
        [_operandStack push:@(answer)];
        a = _operatorStack.peek;
    }
}

- (BOOL) isOperator:(NSString *)string {
    NSArray *allOperators =  @[or, and, openBracket, closeBracket];
    return [allOperators containsObject:string];
}

- (BOOL) evaluate {
    for (NSString *exp in _expression) {
        if ([exp isEqualToString:@")"]) {
            [self evaluateStack];
        } else if ([self isOperator:exp]) {
            [self pushOperator:exp];
        } else {
            [self pushOperand:[exp boolValue]];
        }
    }
    while (_operatorStack.count > 0) {
        [self evaluateStack];
    }
    return _operandStack.pop;
}

@end
