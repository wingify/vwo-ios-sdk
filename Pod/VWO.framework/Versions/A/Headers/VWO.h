/*!
 @header    VAO.h
 @abstract  VAO iOS SDK Header
 @version   1.0
 @copyright Copyright 2014 Wingify Software Pvt. Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface VWO : NSObject
+ (NSDictionary*)allObjects;
+ (id)objectForKey:(NSString*)key;
+ (id)objectForKey:(NSString*)key defaultObject:(id)defaultObject;
+ (void)markConversionForGoal:(NSString*)goal;
+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value;
@end
