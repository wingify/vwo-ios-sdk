//
//  VWOMessageQueue.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import "VWOQueue.h"
#import "VWOLogger.h"

@interface VWOQueue ()

@property NSURL *fileURL;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation VWOQueue

+ (instancetype)queueWithFileURL:(NSURL *)fileURL {
    return [[self alloc] initWithFileURL:fileURL];
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [self init];
    if (self) {
        self.fileURL = fileURL;
        VWOLogDebug(@"QUEUE initialising %@", fileURL.lastPathComponent);
        if (![NSFileManager.defaultManager fileExistsAtPath:fileURL.path]){
            [@[] writeToURL:fileURL atomically:true];
            VWOLogDebug(@"QUEUE File created : %@", fileURL);
        }
        _queue = dispatch_queue_create("vwo.messages", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

    // Enqueue only these types as NSArry.writeToFile only works for these types
    // NSString //NSData //NSDate //NSNumber //NSArray //NSDictionary
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
    return count;
}

@end
