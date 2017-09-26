//
//  VWOMessageQueue.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import "VWOMessageQueue.h"
#import "VWOCampaign.h"
#import "VWOGoal.h"
#import "VWOLogger.h"

NSTimeInterval kTimerIntervalMQ = 20.0;
NSUInteger kQueueThreshold = 5;

@interface VWOMessageQueue ()

@property NSURL *fileURL;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation VWOMessageQueue

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [self init];
    if (self) {
        self.fileURL = fileURL;
        VWOLogDebug(@"QUEUE initialising");
        if (![NSFileManager.defaultManager fileExistsAtPath:fileURL.path]){
            [@[] writeToURL:fileURL atomically:true];
            VWOLogDebug(@"QUEUE File created : %@", fileURL);
        }
        _queue = dispatch_queue_create("vwo.messages", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)enqueue:(NSDictionary *)object {
    VWOLogDebug(@"QUEUE Enqueue : %@", object);
    dispatch_barrier_async(_queue, ^{
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfURL:_fileURL];
        assert(array != nil);
        [array addObject:object];
        [array writeToURL:_fileURL atomically:YES];
    });
}

- (NSDictionary *)dequeue {
    __block NSDictionary *firstObject = nil;
    dispatch_barrier_sync(_queue, ^{
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfURL:_fileURL];
        if (array.count == 0) {
            VWOLogException(@"Trying to remove from empty queue. NOP");
            return;
        }

        firstObject = array.firstObject;
        [array removeObjectAtIndex:0];
        [array writeToURL:_fileURL atomically:YES];
    });
    return firstObject;
}

- (NSDictionary *)peek {
    __block NSDictionary *firstObject;
    dispatch_sync(_queue, ^{
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfURL:_fileURL];
        firstObject = array.firstObject;
    });
    return firstObject;
}

- (NSUInteger) count {
    __block NSUInteger count;
    dispatch_sync(_queue, ^{
        count = [NSArray arrayWithContentsOfURL:_fileURL].count;
    });
    VWOLogDebug(@"QUEUE count %lu", count);
    return count;
}

@end
