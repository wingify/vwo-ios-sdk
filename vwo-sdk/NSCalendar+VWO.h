//
//  NSCalendar+VWO.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 19/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCalendar(VWO)

@property (class, readonly, nonatomic) NSInteger dayOfWeek;
@property (class, readonly, nonatomic) NSInteger hourOfTheDay;

@end

NS_ASSUME_NONNULL_END
