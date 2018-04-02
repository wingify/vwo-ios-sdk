//
//  VWOURLQueue.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 12/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VWOURLQueue;

@protocol VWOURLQueueDelegate <NSObject>
/**
 Invoked when retryCount of an URL becomes zero.
 */
- (void) retryCountExhaustedForURL:(NSURL *)url atFileURLPath:(NSURL *)fileURL;
@end

/**
 VWOURLQueue is a wrapper to VWOQueue.
 It stores a dictionary with keys: "url", "retryCount" & "description"
 Eg:
 {"url": "http://vwo.com/trackuser",
 "retryCount":10,
 "description":"URL to track user"
 */
@interface VWOURLQueue : NSObject

@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, weak) id <VWOURLQueueDelegate> delegate;

+ (instancetype)queueWithFileURL:(NSURL *)fileURL;
- (void)enqueue:(NSURL *)url maxRetry:(int)retryCount description:(nullable NSString *)description;
- (void)flush;

@end

NS_ASSUME_NONNULL_END
