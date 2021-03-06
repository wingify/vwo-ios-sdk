//
//  NSURLSession+Synchronous.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 19/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "NSURLSession+Synchronous.h"

// https://github.com/floschliep/NSURLSession-SynchronousTask
@implementation NSURLSession (Synchronous)

- (nullable NSData *)sendSynchronousDataTaskWithURL:(nonnull NSURL *)url
                                  returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                                              error:(NSError *_Nullable*_Nullable)error {
    return [self sendSynchronousDataTaskWithRequest:[NSURLRequest requestWithURL:url] returningResponse:response error:error];
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
