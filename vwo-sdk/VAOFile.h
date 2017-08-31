//
//  VAOFile.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 16/08/17.
//
//

#import <Foundation/Foundation.h>

@interface VAOFile : NSObject

@property (class, readonly, copy) NSURL *activity;
@property (class, readonly, copy) NSURL *messages;
@property (class, readonly, copy) NSURL *campaignCache;

@end
