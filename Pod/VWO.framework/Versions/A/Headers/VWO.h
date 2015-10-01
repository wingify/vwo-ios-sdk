/*!
 @header    VAO.h
 @abstract  VAO iOS SDK Header
 @version   1.0
 @copyright Copyright 2014 Wingify Software Pvt. Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface VWO : NSObject
/**
 *  Launch VWO
 *  Call VWO's server asynchronously to fetch settings
 */
+ (void)launchVWO;

/**
 *  Launch VWO
 *  Call VWO's server asynchronously
 *  It will call passed in code block on completion (success or error)
 */
+ (void)launchVWOWithCallback:(void (^)(void))completionBlock;

/**
 *  Launch VWO
 *  Call VWO's server asynchronously
 *  It will call passed in code block on completion (success or error)
 */
+ (void)launchVWOSynchronously;

/**
 *  Returns all the objects of all the available experiments.
 *  User is made part of ALL the available experiments.
 *  It is recommended to call this method only when you want to use all the objects,
 *  as it makes user part of all the available experiments
 */
+ (NSDictionary*)allObjects;

/**
 *  It searches all the available experiments, identifies the experiment and returns object for the specified key
 *  User is made part of the identified experiment.
 */
+ (id)objectForKey:(NSString*)key;

/**
 *  If any object for the specified key cannot be found, 
 *  it returns the default object.
 *  It is possible if an invalid key is specified OR
 *  It is possible if internet connection is not available and a key is specified 
 *  for which any experiment cannot be found
 */
+ (id)objectForKey:(NSString*)key defaultObject:(id)defaultObject;

/**
 *  Triggers goal for the specified goal string
 *  Each goal is only counted once
 */
+ (void)markConversionForGoal:(NSString*)goal;

/**
 *  Triggers goal with the value for the specified goal string
 *  Each goal is only counted once
 */
+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value;
@end
