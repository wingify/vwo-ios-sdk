//
//  VAOGoal.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>

typedef enum { GoalTypeCustom, GoalTypeRevenue } GoalType;

@interface VAOGoal : NSObject

@property(nonatomic, assign) int id;
@property NSString *identifier;
@property (nonatomic, assign) GoalType type;

- (instancetype)initWithDictionary:(NSDictionary *) goalDict;

@end
