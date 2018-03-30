//
//  VWOUserConfig.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 29/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWOUserConfig : NSObject

/**
 Users that are not to be made part of VWO A/B testing can be opted out.
 */
@property BOOL optOut;

/**
 Custom Variable is used in the cases where developer intends to programatically create segmentation.
 */
@property NSDictionary<NSString *, NSString*> *customVariables;

/**
 Disabling preview would stop VWO from initializing the Socket connection that is done on VWO.launch
 */
@property BOOL disablePreview;

@end
