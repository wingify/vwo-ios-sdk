//
//  VAOGoogleAnalytics.m
//  VAO
//
//  Created by Swapnil on 11/06/15.
//  Copyright (c) 2015 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOGoogleAnalytics.h"
#import "VAORavenClient.h"

@implementation VAOGoogleAnalytics {
    id defaultTracker;
}

+ (instancetype)sharedInstance {
    Class class =  NSClassFromString(@"GAI");
    if (class == nil) {
        VAOLog(@"COULD NOT FIND GAI CLASS. RETURNING...");
        return nil;
    }
    
    static VAOGoogleAnalytics *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        Class class =  NSClassFromString(@"GAI");
        id sharedInstance = [self performSelectorAndReturnValue:NSSelectorFromString(@"sharedInstance") target:class];
        defaultTracker = [sharedInstance valueForKey:@"defaultTracker"];
    }
    return self;
}

- (void)triggerEventWithCategory:(NSString*)category eventAction:(NSString*)action eventLabel:(NSString*)label eventValue:(NSNumber*)value  dimensionName:(NSString*)dimName dimensionValue:(NSNumber*)dimValue {
    
    @try {
        Class dictionaryBuilder = NSClassFromString(@"GAIDictionaryBuilder");
        SEL aSelector = NSSelectorFromString(@"createEventWithCategory:action:label:value:");
        
        if([dictionaryBuilder respondsToSelector:aSelector]) {
            
            id gaiDictionaryBuilder = [self performSelectorAndReturnValue:aSelector
                                                                   target:dictionaryBuilder
                                                                argument1:category
                                                                argument2:action
                                                                argument3:label
                                                                argument4:value];
            
            // if custom dimension is present
            if(dimName && dimValue) {
                Class gaiFileds = NSClassFromString(@"GAIFields");
                SEL dimensionSelector = NSSelectorFromString(@"customDimensionForIndex:");
                NSInvocation *cdInv = [NSInvocation invocationWithMethodSignature:[gaiFileds methodSignatureForSelector:dimensionSelector]];
                [cdInv setSelector:dimensionSelector];
                [cdInv setTarget:gaiFileds];
                
                NSUInteger d = [dimValue unsignedIntegerValue];
                [cdInv setArgument:&(d) atIndex:2];
                [cdInv invoke];
                
                void *fieldDictionary;
                [cdInv getReturnValue:&fieldDictionary];
                id customDimensionString = (__bridge NSDictionary *)fieldDictionary;
                
                id gaiDictionaryWithDimension = [self performSelectorAndReturnValue:NSSelectorFromString(@"set:forKey:")
                                                                             target:gaiDictionaryBuilder
                                                                          argument1:dimName
                                                                          argument2:customDimensionString];
                
                gaiDictionaryBuilder = gaiDictionaryWithDimension;
            }
            
//            VAOLog(@"dictionary = %@", dictionary);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id returnDictionary = [gaiDictionaryBuilder performSelector:NSSelectorFromString(@"build")];
            // trigger on defaultTracker
            [defaultTracker performSelector:NSSelectorFromString(@"send:") withObject:returnDictionary];
#pragma clang diagnostic pop
        }
    }
    @catch (NSException *exception) {
        NSException *selfException = [[NSException alloc] initWithName:NSStringFromSelector(_cmd) reason:[exception description] userInfo:exception.userInfo];
        VAORavenCaptureException(selfException);
        VAORavenCaptureException(exception);
        
    }
    @finally {
        
    }
}

-(id)performSelectorAndReturnValue:(SEL)selector target:(id)target {
    return [self performSelectorAndReturnValue:selector target:target argument1:nil argument2:nil argument3:nil argument4:nil];
}

-(id)performSelectorAndReturnValue:(SEL)selector target:(id)target argument1:(id)arg1 {
    return [self performSelectorAndReturnValue:selector target:target argument1:arg1 argument2:nil argument3:nil argument4:nil];
}

-(id)performSelectorAndReturnValue:(SEL)selector target:(id)target argument1:(id)arg1 argument2:(id)arg2 {
    return [self performSelectorAndReturnValue:selector target:target argument1:arg1 argument2:arg2 argument3:nil argument4:nil];
}

-(id)performSelectorAndReturnValue:(SEL)selector target:(id)target argument1:(id)arg1 argument2:(id)arg2 argument3:(id)arg3 {
    return [self performSelectorAndReturnValue:selector target:target argument1:arg1 argument2:arg2 argument3:arg3 argument4:nil];
}

-(id)performSelectorAndReturnValue:(SEL)selector target:(id)target argument1:(id)arg1 argument2:(id)arg2 argument3:(id)arg3 argument4:(id)arg4 {
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
    [inv setSelector:selector];
    [inv setTarget:target];
    
    if (arg1) {
        [inv setArgument:&arg1 atIndex:2];
    }
    
    if (arg2) {
        [inv setArgument:&arg2 atIndex:3];
    }
    
    if (arg3) {
        [inv setArgument:&arg3 atIndex:4];
    }
    
    if (arg4) {
        [inv setArgument:&arg4 atIndex:5];
    }
    
    [inv invoke];
    
    //http://stackoverflow.com/questions/22018272/nsinvocation-returns-value-but-makes-app-crash-with-exc-bad-access
    void *tempDictionary;
    [inv getReturnValue:&tempDictionary];
    id dictionary = (__bridge NSDictionary *)tempDictionary;
    return dictionary;
}

- (void)goalTriggeredWithName:(NSString*)goalName goalId:(NSString*)goalId goalValue:(NSNumber*)goalValue experimentName:(NSString*)expName experimentId:(NSString*)expId variationName:(NSString*)varName variationId:(NSString*)varId {
    
    NSString *category = [NSString stringWithFormat:@"VWO Goal - %@ - %@", expName, expId];
    NSString *action = [NSString stringWithFormat:@"%@ - %@", goalName, goalId];
    NSString *label = [NSString stringWithFormat:@"%@ - %@", varName, varId];
    
    [self triggerEventWithCategory:category eventAction:action eventLabel:label eventValue:goalValue dimensionName:nil dimensionValue:nil];
}

- (void)experimentWithName:(NSString*)expName experimentId:(NSString*)expId variationName:(NSString*)varName variationId:(NSString*)varId dimension:(NSNumber*)dimValue {
    NSString *category = [NSString stringWithFormat:@"VWO Campaign - %@ - %@", expName, expId];
    NSString *action = [NSString stringWithFormat:@"%@ - %@", expName, expId];
    NSString *label = [NSString stringWithFormat:@"%@ - %@", varName, varId];
    NSString *dimName = [NSString stringWithFormat:@"CamId:%@, VarName:%@", expId, varName];
    
    [self triggerEventWithCategory:category eventAction:action eventLabel:label eventValue:nil dimensionName:dimName dimensionValue:dimValue];
}
@end
