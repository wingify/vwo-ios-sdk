//
//  VWOStack.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOStack : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, readonly) id peek;

- (void)push:(id)object;
- (nullable id)pop;
- (BOOL)isEmpty;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
