//
//  NSCalendar+VWO.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 19/07/17.
//
//

#import "NSCalendar+VWO.h"

@implementation NSCalendar(VWO)

+ (NSInteger)dayOfWeek {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitWeekday fromDate:NSDate.date];
    NSInteger weekday = dateComponents.weekday;

    // start from sunday = 0
    return weekday - 1;
}

+ (NSInteger)hourOfTheDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitHour fromDate:NSDate.date];
    return dateComponents.hour;
}

@end
