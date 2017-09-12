//
//  VWOAPIClient.h
//  VWO
//
//  Created by Wingify on 23/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Handler for all remote communication for VWO_RUN_MODE.
//

#import <Foundation/Foundation.h>

@class VWOCampaign;

@interface VWOAPIClient : NSObject

+ (instancetype)sharedInstance;
- (void)initializeAndStartTimer;
- (void)startTimer;
- (void)stopTimer;

- (void) fetchCampaignsAsynchronouslyOnSuccess:(void(^)(id))successBlock
                                       failure:(void(^)(NSError *))failureBlock;

- (id)fetchCampaignsSynchronouslyForTimeout:(NSTimeInterval)timeout
                                      error:(NSError *__autoreleasing *)error;

- (void)makeUserPartOfCampaign:(VWOCampaign *)campaign;

- (void) markConversionForGoalId:(NSInteger)goalId
                    experimentId:(NSInteger)experimentId
                     variationId:(NSInteger)variationId
                         revenue:(NSNumber *)revenue;

@end
