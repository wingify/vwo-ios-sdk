//
//  VWOMessageQueue.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOMessageQueue : NSObject

+ (instancetype)sharedInstance;
-(void)pushMessage:(NSDictionary *) message;

@end

NS_ASSUME_NONNULL_END
