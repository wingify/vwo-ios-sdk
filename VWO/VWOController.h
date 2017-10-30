//
//  VWOController.h
//  VWO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VWOSegmentEvaluator, VWOConfig;

NS_ASSUME_NONNULL_BEGIN

static NSString *kSDKversion = @"2.0.0-beta10";

@interface VWOController : NSObject

/// All the operations in controller are expected to happen on this queue
@property (class, readonly) dispatch_queue_t taskQueue;
@property VWOSegmentEvaluator *segmentEvaluator;
@property NSDictionary *previewInfo;
@property VWOConfig *config;

+ (instancetype)shared;

- (void)launchWithAPIKey:(NSString *)apiKey
             withTimeout:(nullable NSNumber *)timeout
                 withCallback:(nullable void(^)(void))completionBlock
                      failure:(nullable void(^)(NSString *))failureBlock;

- (void)markConversionForGoal:(NSString *)goal withValue:(nullable NSNumber *)value;
- (nullable id)variationForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
