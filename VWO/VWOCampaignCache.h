//
//  VWOCampaignFetcher.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 30/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "VWOCampaign.h"

NS_ASSUME_NONNULL_BEGIN

@class VWOCampaign, VWOSegmentEvaluator;

/**
 VWOCampaignCache provides functionality to manage the campaign caching
 */
@interface VWOCampaignCache : NSObject

/**
 Write the content of campaign cache to settings file

 @param settingsFile Settings file that is provided by the developer
 */
+ (void)writeFromSettingsFile:(NSString *)settingsFile to:(NSURL *)cacheLocation;


/**
 Updates the cache by response received by sending request on the specified URL
 */
+ (void)writeFromNetworkResponse:(NSURL *)url
                       timeout:(NSTimeInterval)timeout
                              to:(NSURL *)cacheLocation
                           error:(NSString * _Nullable *)errorString;

/**
 Reads campaign info from cache and returns it in Array of VWOCampaign type
 */
+ (nullable NSArray<VWOCampaign *> *)getCampaingsFromCache:(NSURL *)cacheLocation
                                               error:(NSString **)errorString;

@end

NS_ASSUME_NONNULL_END
