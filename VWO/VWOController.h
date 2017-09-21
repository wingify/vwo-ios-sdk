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

@property (assign) BOOL previewMode;
@property VWOSegmentEvaluator *segmentEvaluator;

+ (instancetype)sharedInstance;
- (void)initializeAsynchronously:(BOOL)async
                         timeout:(NSTimeInterval)timeout
                    withCallback:(void(^)(void))completionBlock
                         failure:(void(^)(void))failureBlock;
- (void)preview:(NSDictionary *)changes;
- (void)markConversionForGoal:(NSString *)goal withValue:(nullable NSNumber *)value;
- (nullable id)variationForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
