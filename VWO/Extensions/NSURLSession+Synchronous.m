//
//  NSURLSession+Synchronous.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 19/09/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import "NSURLSession+Synchronous.h"
#import "VWOUserDefaults.h"
#import "VWOConstants.h"

// https://github.com/floschliep/NSURLSession-SynchronousTask
@implementation NSURLSession (Synchronous)

- (nullable NSData *)sendSynchronousDataTaskWithURL:(nonnull NSURL *)url
                                  returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                                              error:(NSError *_Nullable*_Nullable)error {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if(VWOUserDefaults.IsEventArchEnabled != NULL && [VWOUserDefaults.IsEventArchEnabled isEqual:EventArchEnabled]){
        //this code block handles network requests for Data360 EventArch calls
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:UserAgentValue forHTTPHeaderField:@"User-Agent"];
        
        if(VWOUserDefaults.EventArchData != NULL){
            NSString *urlString = [url absoluteString];
            NSMutableDictionary *eventArchData = VWOUserDefaults.EventArchData;
            NSDictionary *payloadEventArch = [eventArchData objectForKey:urlString];
            
            if(payloadEventArch != NULL){
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payloadEventArch options:NSJSONWritingPrettyPrinted error:nil];
                [urlRequest setHTTPBody:jsonData];
                [VWOUserDefaults removeEventArchDataItem:urlString];
            }
        }
        
        return [self sendSynchronousDataTaskWithRequest:urlRequest returningResponse:response error:error];
    }
    
    NSMutableDictionary *networkHTTPMethodTypeData = VWOUserDefaults.NetworkHTTPMethodTypeData;
    if(networkHTTPMethodTypeData != NULL){
        //this code block handles network requests MethodType
        NSString *urlString = [url absoluteString];
        NSString *networkHTTPMethodTypeForURL = [networkHTTPMethodTypeData objectForKey:urlString];
        
        if(networkHTTPMethodTypeForURL != NULL && networkHTTPMethodTypeForURL.length != 0){
            [urlRequest setHTTPMethod: networkHTTPMethodTypeForURL];
        }
    }
    return [self sendSynchronousDataTaskWithRequest:urlRequest returningResponse:response error:error];
}

- (nullable NSData *)sendSynchronousDataTaskWithRequest:(nonnull NSURLRequest *)request
                                      returningResponse:(NSURLResponse *_Nullable __autoreleasing *_Nullable)response
                                                  error:(NSError *_Nullable __autoreleasing *_Nullable)error {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *data = nil;
    __block NSError *_error = nil;
    __block NSURLResponse *_response = nil;
    [[self dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *taskResponse, NSError *taskError) {
        data = taskData;
        if (taskResponse) {
            _response = taskResponse;
        }
        if (taskError) {
            _error = taskError;
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (error) *error = _error;
    if (response) *response = _response;
    return data;
}

@end
