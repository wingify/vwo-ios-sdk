//
//  NSDate+VWO.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 17/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "NSDate+VWO.h"

@implementation NSDate(VWO)

- (NSInteger)dayOfWeek {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitWeekday fromDate:self];
    NSInteger weekday = dateComponents.weekday;
    return weekday - 1; // start from sunday = 0
}

- (NSInteger)hourOfTheDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitHour fromDate:self];
    return dateComponents.hour;
}

@end
