//
//  VAOGoal.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GoalType) {
    GoalTypeCustom,
    GoalTypeRevenue
};

@interface VAOGoal : NSObject<NSCoding>

@property(nonatomic, assign) int id;
@property NSString *identifier;
@property (nonatomic, assign) GoalType type;

- (instancetype)initWithDictionary:(NSDictionary *) goalDict;

@end
