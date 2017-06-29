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

+ (NSString*)generateUUID {
    NSString *UUID = [[NSUUID UUID] UUIDString];
    UUID = [UUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return UUID;
}

+ (NSString *)getUUID{
    static NSString *deviceId = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        deviceId = [defaults objectForKey:@"vaoUUID"];
        if(deviceId == nil){
            deviceId = [self generateUUID];
            [defaults setValue:deviceId forKey:@"vaoUUID"];
            [defaults synchronize];
        }
    });
    return deviceId;
}

+ (void)incrementSessionNumber {
    // set and increment session
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *session = [defaults objectForKey:VAO_SESSION_KEY];
    if(session == nil){
        session = @1;
        [self setIsNewVisitor:YES];
    } else {
        session = [NSNumber numberWithDouble:[session doubleValue] + 1];
    }
    
    [defaults setValue:session forKey:VAO_SESSION_KEY];
    [defaults synchronize];
}

+ (NSNumber *)getSessionNumber {
    static NSNumber *session = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        session = [defaults objectForKey:VAO_SESSION_KEY];
    });
    return session;
}

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
