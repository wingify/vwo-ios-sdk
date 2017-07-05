//
//  VAOUtils.m
//  VAO
//
//  Created by Wingify on 23/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOUtils.h"
#import <objc/runtime.h>
#import <sys/utsname.h>

static NSString *_token;

@implementation VAOUtils

+ (void)setIsNewVisitor:(BOOL)newVisitor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:newVisitor forKey:@"vaoNewVisitor"];
}

+ (BOOL)getIsNewVisitor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"vaoNewVisitor"];
}

@end

