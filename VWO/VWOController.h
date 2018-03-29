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

static NSString *kSDKversion = @"2.2.1";
static BOOL kPreviewEnabled = YES;

@interface VWOController : NSObject

/// All the operations in controller are expected to happen on taskQueue queue
@property (class, readonly) dispatch_queue_t taskQueue;
@property NSMutableDictionary<NSString *, NSString *> *customVariables;
@property NSDictionary *previewInfo;
@property VWOConfig *config;
@property (getter=isInitialised) BOOL initialised;

+ (instancetype)shared;

- (void)launchWithAPIKey:(NSString *)apiKey
                  optOut:(BOOL)optOut
             withTimeout:(nullable NSNumber *)timeout
            withCallback:(nullable void(^)(void))completionBlock
                 failure:(nullable void(^)(NSString *))failureBlock;

- (void)trackConversion:(NSString *)goal withValue:(nullable NSNumber *)value;
- (nullable id)variationForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
