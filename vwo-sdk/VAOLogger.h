//
//  VAOLogger.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

@interface VAOLogger : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

+ (void)debug: (NSString *) debug;
+ (void)info:(NSString *) info;
+ (void)warning:(NSString *) warning;
+ (void)error:(NSString *) error;

@end
