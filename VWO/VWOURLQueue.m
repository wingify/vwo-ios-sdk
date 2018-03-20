//
//  VWOURLQueue.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 12/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOURLQueue.h"
#import "VWOQueue.h"
#import "NSURLSession+Synchronous.h"
#import "VWOLogger.h"

static NSString *const kURL         = @"url";
static NSString *const kMaxRetry    = @"retry";
static NSString *const kDescription = @"desc";

@interface VWOURLQueue ()
@property (nonatomic) VWOQueue *queue;
@property BOOL isFlushing;
@end

@implementation VWOURLQueue

+ (instancetype)queueWithFileURL:(NSURL *)fileURL {
    return [[self alloc] initWithFileURL:fileURL];
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [self init];
    if (self) {
        self.path = fileURL;
        self.queue = [VWOQueue queueWithFileURL:fileURL];
    }
    return self;
}

- (void)enqueue:(NSURL *)url maxRetry:(int)retryCount description:(NSString *)description {
    NSMutableDictionary *dict = [@{kURL : url.absoluteString, kMaxRetry : @(retryCount)} mutableCopy];
    if (description != nil) { dict[kDescription] = description; }
    [_queue enqueue:dict];
}

/**
 Flush all the URLS present in the Queue.
 Internally its been dispatched on low priority background thread
 */
- (void)flush {
    if (_isFlushing) return;
    _isFlushing = true;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSUInteger count = self.queue.count;
        VWOLogDebug(@"Flush Queue. Count %d", count);
        for (; count > 0; count -= 1) {
            NSAssert(self.queue.peek != nil, @"queue.peek is giving invalid results");

            NSMutableDictionary *peekObject = [self.queue.peek mutableCopy];

            NSURL *url =  [NSURL URLWithString:peekObject[kURL]];
            NSError *error = nil;
            NSURLResponse *response = nil;
            VWOLogDebug(@"Sending request %@", url);
            [NSURLSession.sharedSession sendSynchronousDataTaskWithURL:url
                                                     returningResponse:&response
                                                                 error:&error];

                //If No internet connection break; No need to process other messages in queue
            if (error.code == NSURLErrorNotConnectedToInternet) {
                VWOLogWarning(@"No internet connection. Flush aborted");
                self.isFlushing = false;
                break;
            }
                // Failure is confirmed only when status is not 200
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            int retryCount = [peekObject[kMaxRetry] intValue];
            if (statusCode == 200){
                VWOLogInfo(@"Successfully sent message %d", statusCode);
                [self.queue dequeue];
            } else if (retryCount <= 0) {
                VWOLogInfo(@"Retry count exhausted %@", url);
                [self.delegate retryCountExhaustedPath:self.path url:url];
                [self.queue dequeue];
            } else {
                peekObject[kMaxRetry] = @(retryCount - 1);
                VWOLogDebug(@"Re inserting %@ with retry count %@",url, peekObject[kMaxRetry]);
                [self.queue dequeue];
                [self.queue enqueue:peekObject];
            }
        }//for
        self.isFlushing = false;
    });
}

@end
