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

+ (NSString*)vaoAccountIdAppKeyCombination {
    NSString *combination = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"VWOAppKey"];
    return combination;
}

+ (NSString*)vaoAccountId {
    NSString *accountId = [self vaoAccountIdAppKeyCombination];
    if ([[accountId componentsSeparatedByString:@"-"] count] == 2) {
        return [[accountId componentsSeparatedByString:@"-"] objectAtIndex:1];
    }
    return nil;
}

+ (NSString*)vaoAppKey {
    NSString *accountId = [self vaoAccountIdAppKeyCombination];
    if ([[accountId componentsSeparatedByString:@"-"] count] == 2) {
        return [[accountId componentsSeparatedByString:@"-"] objectAtIndex:0];
    }
    return nil;
}

+ (NSInteger)majoriOSversion {
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSArray *versionsArray = [iOSVersion componentsSeparatedByString:@"."];
    NSInteger majorVersion = [versionsArray[0] integerValue];
    return majorVersion;
}

+ (NSString*)deviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
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


void VAOMethodSwizzle(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // ...
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

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
