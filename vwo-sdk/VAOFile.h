//
//  VAOFile.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 16/08/17.
//
//

#import <Foundation/Foundation.h>

@interface VAOFile : NSObject

@property (class, readonly, copy) NSURL *activityPath;
@property (class, readonly, copy) NSURL *messagesPath;
@property (class, readonly, copy) NSURL *campaignCachePath;

@end
