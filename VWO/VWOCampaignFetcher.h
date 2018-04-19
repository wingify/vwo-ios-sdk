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

typedef NSArray <VWOCampaign *> VWOCampaignArray;

@property VWOSegmentEvaluator *evaluator;


- (instancetype)initWithURL:(NSURL *)url
                    timeout:(NSNumber *)timeout
            customVariables:(nullable NSDictionary *)customVariables;

- (void)updateCacheOnceFromSettingsFileNamed:(NSString *)fileName;

- (nullable VWOCampaignArray *)fetchWithCallback:(nullable void(^)(void))completion
                                         failure:(nullable void(^)(NSString *error))failure;

@end

NS_ASSUME_NONNULL_END
