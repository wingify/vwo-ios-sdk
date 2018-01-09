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

static NSString *or = @"|";
static NSString *and = @"&";
static NSString *openBracket = @"(";
static NSString *closeBracket = @")";

- (instancetype)init {
    if (self = [super init]) {
        _operandStack = [VWOStack new];
        _operatorStack = [VWOStack new];
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
    if ([operator  isEqual: and]) {
        return lhs && rhs;
    } else if([operator  isEqual: or]) {
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
    while ( ![a isEqualToString:@"("] && !_operatorStack.isEmpty) {
        NSString *operator = _operatorStack.pop;
        BOOL rhs = [_operandStack.pop boolValue];
        BOOL lhs = [_operandStack.pop boolValue];
        BOOL answer = [self evaluteOperator:operator forLHS:lhs RHS:rhs];
        [_operandStack push:@(answer)];
        a = _operatorStack.peek;
    }
}

- (BOOL) isOperator:(NSString *)string {
    NSArray *allOperators =  @[or, and, openBracket, closeBracket];
    return [allOperators containsObject:string];
}

- (BOOL) evaluate:(NSArray <NSString *>*) expression {
    [_operandStack clear];
    [_operatorStack clear];
    for (NSString *exp in expression) {
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
    return [_operandStack.pop boolValue];
}

@end
