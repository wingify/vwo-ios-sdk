//
//  VAOGoogleAnalytics.h
//  VAO
//
//  Created by Swapnil on 11/06/15.
//  Copyright (c) 2015 Wingify Software Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VAOGoogleAnalytics : NSObject
+ (id)sharedInstance;
- (void)goalTriggeredWithName:(NSString*)goalName
                       goalId:(NSString*)goalId
                    goalValue:(NSNumber*)goalValue
               experimentName:(NSString*)expName
                 experimentId:(NSString*)expId
                variationName:(NSString*)varName
                  variationId:(NSString*)varId;

- (void)experimentWithName:(NSString*)expName
              experimentId:(NSString*)expId
             variationName:(NSString*)varName
               variationId:(NSString*)varId
                 dimension:(NSNumber*)dimValue;
@end
