//
//  VWOMessageQueue.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOMessageQueue : NSObject

@property (readonly) NSUInteger count;
@property (nullable, readonly) NSDictionary *peek;

- (instancetype)initwithFileURL:(NSURL *)fileURL;
- (void)enqueue:(NSDictionary *)object;
- (void)removeFirst;


@end

NS_ASSUME_NONNULL_END
