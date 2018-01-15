//
//  VWOInfixEvaluator.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import "VWOInfixEvaluator.h"
#import "VWOStack.h"

@implementation VWOInfixEvaluator

static NSString *or = @"|";
static NSString *and = @"&";
static NSString *openBracket = @"(";
static NSString *closeBracket = @")";


+ (BOOL)evaluteOperator:(NSString *)operator forLHS:(BOOL)lhs RHS:(BOOL)rhs {
    if ([operator  isEqual: and]) {
        return lhs && rhs;
    } else {
        return lhs || rhs;
    }
}

+ (void)evaluateSubExpressionForOperandStack:(VWOStack *)operandStack
                               operatorStack:(VWOStack *)operatorStack {

    if ([operatorStack.peek isEqualToString:@"("]) {
        [operatorStack pop];
        return;
    }
    NSString *peek;
    while ( ![peek isEqualToString:@"("] && !operatorStack.isEmpty) {
        NSString *operator = operatorStack.pop;
        BOOL rhs = [operandStack.pop boolValue];
        BOOL lhs = [operandStack.pop boolValue];
        BOOL answer = [self evaluteOperator:operator forLHS:lhs RHS:rhs];
        [operandStack push:@(answer)];
        peek = operatorStack.peek;
    }
}

+ (BOOL)isOperator:(NSString *)string {
    NSArray *allOperators =  @[or, and, openBracket, closeBracket];
    return [allOperators containsObject:string];
}

+ (BOOL)evaluate:(NSArray <NSString *>*)expression {
    VWOStack *_operandStack = [VWOStack new];
    VWOStack * _operatorStack = [VWOStack new];
    for (NSString *exp in expression) {
        if ([exp isEqualToString:@")"]) {
            [self evaluateSubExpressionForOperandStack:_operandStack operatorStack:_operatorStack];
        } else if ([self isOperator:exp]) {
            [_operatorStack push:exp];
        } else {
            [_operandStack push:@([exp boolValue])];
        }
    }
    while (_operatorStack.count > 0) {
        [self evaluateSubExpressionForOperandStack:_operandStack operatorStack:_operatorStack];
    }
    return [_operandStack.pop boolValue];
}

@end
