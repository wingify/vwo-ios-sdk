//
//  VAOAPIClient.h
//  VAO
//
//  Created by Wingify on 23/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Handler for all remote communication for VAO_RUN_MODE.
//

#import <Foundation/Foundation.h>

@interface VAOAPIClient : NSObject

+ (instancetype)sharedInstance;
- (void)schedule;
- (void)applicationWillEnterForeground;
- (void)applicationDidEnterBackground;
- (void)optOut:(BOOL)status;

// For App
- (void) pullABData:(NSMutableDictionary *)experimentsAndVariationsPair
            success:(void(^)(id))successBlock
            failure:(void(^)(NSError *))failureBlock
      isSynchronous:(BOOL)synchronous;

- (void) pushVariationRenderWithExperimentId:(NSInteger)experimentId
                                 variationId:(NSString *)variationId;

- (void) pushGoalConversionWithGoalId:(NSInteger)goalId
                         experimentId:(NSInteger)experimentId
                          variationId:(NSString *)variationId
                              revenue:(NSNumber*)revenue;

@end
