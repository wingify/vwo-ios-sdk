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
- (void) retryCountExhaustedPath:(NSURL *)path url:(NSURL *)url;
@end

@interface VWOURLQueue : NSObject

@property (nonatomic) NSURL *path;
@property (nonatomic, weak) id <VWOURLQueueDelegate> delegate;

+ (instancetype)queueWithFileURL:(NSURL *)fileURL;
- (void)enqueue:(NSURL *)url maxRetry:(int)retryCount description:(NSString *)description;
- (void)flush;

@end

NS_ASSUME_NONNULL_END
