//
//  VWOCampaignFetcher.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 30/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VWOCampaign, VWOSegmentEvaluator;

@interface VWOCampaignFetcher : NSObject
+ (nullable NSArray<VWOCampaign *> *)getCampaignsWithTimeout:(NSNumber *)timeout
                                                         url:(NSURL *)url
                                             customVariables:(NSDictionary<NSString *, NSString *> *)customVariables
                                                withCallback:(void(^)(void))completionBlock
                                                     failure:(void(^)(NSString *error))failureBlock;
@end

NS_ASSUME_NONNULL_END
