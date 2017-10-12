//
//  VWOURLPendingQueue.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 12/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOURLPendingQueue.h"
#import "VWOQueue.h"
#import "NSURLSession+Synchronous.h"
#import "VWOLogger.h"

static NSString *const kURL               = @"url";
static NSString *const kRetryCount        = @"retry";
static NSTimeInterval kMaxTotalRetryCount = 10;

@interface VWOURLPendingQueue ()
@property (nonatomic) VWOQueue *queue;
@end

@implementation VWOURLPendingQueue

+ (instancetype)queueWithFileURL:(NSURL *)fileURL {
    return [[self alloc] initWithFileURL:fileURL];
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [self init];
    if (self) {
        self.queue = [[VWOQueue alloc] initWithFileURL:fileURL];
    }
    return self;
}

- (void)enqueue:(NSURL *)url retryCount:(int)retryCount {
    [_queue enqueue:@{kURL : url.absoluteString, kRetryCount : @(retryCount)}];
}

/**
 Flush all the URLS present in the Queue.
 Internally its been dispatched on low priority background thread

 @param sendAll If set will try to hit all the URLS irrespective of the error
 */
- (void)flushSendAll:(BOOL)sendAll {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSUInteger count = _queue.count;
        VWOLogDebug(@"Flush Queue. Count %d", count);
        for (; count > 0; count -= 1) {
            NSAssert(_queue.peek != nil, @"queue.peek is giving invalid results");

            NSMutableDictionary *peekObject = [_queue.peek mutableCopy];

            NSString *url = peekObject[kURL];
            NSError *error = nil;
            NSURLResponse *response = nil;
            VWOLogDebug(@"Sending request %@", url);
            [NSURLSession.sharedSession sendSynchronousDataTaskWithURL:[NSURL URLWithString:url] returningResponse:&response error:&error];

                //If No internet connection break; No need to process other messages in queue
            if (error != nil) {
                VWOLogError(error.localizedDescription);
                if (sendAll == false) break;
            }

                // Failure is confirmed only when status is not 200
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            int retryCount = [peekObject[kRetryCount] intValue];
            if (statusCode == 200 || retryCount > kMaxTotalRetryCount){
                VWOLogInfo(@"Successfully sent message %d", statusCode);
                [_queue dequeue];
            } else {
                peekObject[kRetryCount] = @(retryCount + 1);
                VWOLogDebug(@"Re inserting message with retry count %@", peekObject[kRetryCount]);
                [_queue dequeue];
                [_queue enqueue:peekObject];
            }
        }//for
    });
}

@end
