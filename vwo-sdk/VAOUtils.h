//
//  VAOUtils.h
//  VAO
//
//  Created by Wingify on 23/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Misc. utility code.
//


#import <Foundation/Foundation.h>

@interface VAOUtils : NSObject

+ (NSString*)getUUID;
/**
 *  increments and sets session number
 *  also set new visitor for first run
 */
+ (void)incrementSessionNumber;
+ (NSNumber*)getSessionNumber;
+ (void)setIsNewVisitor:(BOOL)newVisitor;
+ (BOOL)getIsNewVisitor;
+ (NSString*)deviceType;
@end

