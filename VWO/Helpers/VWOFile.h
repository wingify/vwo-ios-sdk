//
//  VWOFile.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 16/08/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOFile : NSObject

@property (class, readonly, copy) NSURL *campaignCache;
@property (class, readonly, copy) NSURL *messageQueue;
@property (class, readonly, copy) NSURL *failedMessageQueue;

@end

NS_ASSUME_NONNULL_END
