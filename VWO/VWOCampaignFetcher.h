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

/**
 Fetch campaigns from network or settings file

 @param errorString Error message incase of failure
 @return nil if some error occurred while fetching. Returns empty array @[] if no campaigns are received
 */
- (nullable VWOCampaignArray *)fetch:(NSString **)errorString;

@end

NS_ASSUME_NONNULL_END
