//
//  VAOMessageQueue.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 06/07/17.
//
//

#import <Foundation/Foundation.h>

@interface VAOMessageQueue : NSObject

+ (instancetype)sharedInstance;
-(void)pushMessage:(NSDictionary *) message;

@end
