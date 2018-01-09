//
//  VWOInfixEvaluator.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOInfixEvaluator : NSObject

- (instancetype)initWithExpression:(NSArray *) expression;

- (BOOL) evaluate;

@end

NS_ASSUME_NONNULL_END
