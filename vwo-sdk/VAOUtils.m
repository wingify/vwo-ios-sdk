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


#if defined(DEBUG) || TARGET_IPHONE_SIMULATOR
void VAOLogImpl(const char *functionName, int lineNumber, NSString *format, ...) {
#ifndef DEBUG
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"VWOLoquacious"] == nil &&
       [[[NSProcessInfo processInfo] arguments] containsObject:@"--vwo_loquacious"] == NO
    ){
        return;
    }
#endif
    
    if(functionName[0] == '+' || functionName[0] == '-'){ // class method
        functionName += 2;
        
        if(strstr(functionName, "VAO") == functionName){ // class name starts with VAO
            functionName += 3; // skip VAO
        }
    }

    va_list args;
    va_start(args, format);
    NSString *newFormat = [NSString stringWithFormat:@"%6.6s(%3.3d): %@", functionName, lineNumber, format];
    NSLogv(newFormat, args);
    va_end(args);
}
#endif
