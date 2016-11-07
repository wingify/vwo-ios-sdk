//
//  VAOController.h
//  VAO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Controller (of MVC fame) for the whole SDK. This is the centerpiece of most decision making.
//

#import <Foundation/Foundation.h>

@interface VAOController : NSObject

+ (instancetype)sharedInstance;
+ (void)initializeAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidEnterPreviewMode;
- (void)applicationDidExitPreviewMode;
- (void)previewMeta:(NSDictionary *)changes;
- (void)setValue:(NSString*)value forCusomtorVariable:(NSString*)variable;
- (void)trackUserManually;
// Goals
- (void)markConversionForGoal:(NSString*)goal withValue:(NSNumber*)value;

// json Methods
- (id)objectForKey:(NSString*)key;
- (void)trackUserInCampaign:(NSString*)key;
@end
