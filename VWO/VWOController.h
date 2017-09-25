//
//  VWOController.h
//  VWO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Controller (of MVC fame) for the whole SDK. This is the centerpiece of most decision making.
//

#import <Foundation/Foundation.h>

@class VWOSegmentEvaluator;

NS_ASSUME_NONNULL_BEGIN

@interface VWOController : NSObject

@property (class, readonly) dispatch_queue_t taskQueue;

@property (assign) BOOL previewMode;
@property VWOSegmentEvaluator *segmentEvaluator;
@property (assign) BOOL isInitialized;

+ (instancetype)sharedInstance;

- (void)launchWithAPIKey:(NSString *)apiKey
             withTimeout:(nullable NSNumber *)timeout
                 withCallback:(nullable void(^)(void))completionBlock
                      failure:(nullable void(^)(void))failureBlock;

- (void)markConversionForGoal:(NSString *)goal withValue:(nullable NSNumber *)value;
- (nullable id)variationForKey:(NSString *)key;
- (void)preview:(NSDictionary *)changes;

@end

NS_ASSUME_NONNULL_END
