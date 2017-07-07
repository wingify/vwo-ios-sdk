//
//  VAOMessageQueue.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import "VAOMessageQueue.h"

NSTimeInterval kTimerIntervalMQ = 20.0;
NSUInteger kQueueThreshold = 5;

@implementation VAOMessageQueue {
    NSTimer *timer;
    NSMutableArray *queue;
    BOOL inTransition;
}

+ (instancetype)sharedInstance {
    static VAOMessageQueue *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        timer = [NSTimer scheduledTimerWithTimeInterval:kTimerIntervalMQ
                                                 target:self
                                               selector:@selector(timerActivity)
                                               userInfo:nil
                                                repeats:YES];
        queue = [NSMutableArray array];//TODO: Check if there are any messages in file
        inTransition = NO;
    }
    return self;
}

- (void)timerActivity {
    [self flushMessages];
}

-(void)pushMessage:(NSDictionary *) message {
    [queue addObject:message];
    
    if (queue.count > kQueueThreshold) {
        [self flushMessages];
    }
}

-(void)flushMessages {
    inTransition = YES;
    //Send all messages in message queue
    for (NSDictionary *message in queue) {
//        [NetworkManager sendMessage:message completion:^{
//            mark message as sent;
//        }];
    }
    
    //Remove all the messages that are marked as sent
    inTransition = NO;
}

@end
