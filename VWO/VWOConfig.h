//
//  VWOUserConfig.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 29/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWOConfig : NSObject

/**
 Users that are not to be made part of VWO A/B testing can be opted out.
 */
@property BOOL optOut;

/**
 Custom Variable is used in the cases where developer intends to programatically create segmentation.
 */
@property NSDictionary<NSString *, NSString*> *customVariables;

@property NSString *customDimension;

/**
 Disabling preview would stop VWO from initializing the Socket connection that is done on VWO.launch
 Preview is enabled by default
 */
@property BOOL disablePreview;

@property NSString *userID;

- (void)setCustomDimension:(NSString *)customDimensionKey withCustomDimensionValue:(NSString*) customDimensionValue
                                        NS_SWIFT_NAME(setCustomDimension(customDimensionKey:customDimensionValue:));

@end
