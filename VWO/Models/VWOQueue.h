//
//  VWOMessageQueue.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 VWOQueue is a thread safe persistent queue.
 Every mutating operation on queue is made persistent immediately, due to which
 the queue is consistent over launches.
 */
@interface VWOQueue : NSObject

@property NSURL *fileURL;
@property (readonly) NSUInteger count;
@property (nullable, readonly) NSDictionary *peek;

/**
 Creates an empty file backed queue.

 @param fileURL Location where queue is to be stored
 @return VWOQueue object
 */
+ (instancetype)queueWithFileURL:(NSURL *)fileURL;
- (void)enqueue:(NSDictionary *)object;
- (nullable NSDictionary *) dequeue;

@end

NS_ASSUME_NONNULL_END
