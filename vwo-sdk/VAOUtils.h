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
+ (void)setIsNewVisitor:(BOOL)newVisitor;
+ (BOOL)getIsNewVisitor;
@end

