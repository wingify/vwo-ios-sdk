//
//  NSDate+VWO.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 17/11/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (VWO)

@property (assign, readonly) NSInteger dayOfWeek;
@property (assign, readonly) NSInteger hourOfTheDay;

@end

NS_ASSUME_NONNULL_END
