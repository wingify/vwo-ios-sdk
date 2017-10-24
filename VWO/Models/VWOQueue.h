//
//  VWOMessageQueue.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOQueue : NSObject

@property (readonly) NSUInteger count;
@property (nullable, readonly) NSDictionary *peek;

+ (instancetype)queueWithFileURL:(NSURL *)fileURL;
- (void)enqueue:(NSDictionary *)object;
- (nullable NSDictionary *) dequeue;

@end

NS_ASSUME_NONNULL_END
