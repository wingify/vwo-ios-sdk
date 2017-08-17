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

@property (assign) BOOL previewMode;

+ (instancetype)sharedInstance;
+ (void)initializeAsynchronously:(BOOL)async
                    withCallback:(void(^)(void))completionBlock
                         failure:(void(^)(void))failureBlock;
- (void)preview:(NSDictionary *)changes;
- (void)markConversionForGoal:(NSString *)goal withValue:(NSNumber *)value;
- (id)variationForKey:(NSString *)key;
- (void)setCustomVariable:(NSString *)variable withValue:(NSString *)value;

@end
