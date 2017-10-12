//
//  VWOURLQueue.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 12/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOURLQueue : NSObject

+ (instancetype)queueWithFileURL:(NSURL *)fileURL;

- (void)enqueue:(NSURL *)url retryCount:(int)retryCount;

- (void)flushSendAll:(BOOL)sendAll;

@end

NS_ASSUME_NONNULL_END
