//
//  VWOMessageQueue.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOMessageQueue : NSObject

@property (readonly) NSUInteger count;
@property (nullable, readonly) NSDictionary *peek;

- (instancetype)initWithFileURL:(NSURL *)fileURL;

/// Enqueue only these types as NSArry.writeToFile only works for these types
// NSString
//NSData
//NSDate
//NSNumber
//NSArray
//NSDictionary
- (void)enqueue:(NSDictionary *)object;

- (nullable NSDictionary *) dequeue;

@end

NS_ASSUME_NONNULL_END
