//
//  VAOAFHTTPRequestOperationManager+Synchronous.m
//  VWO
//
//  Created by Swapnil on 29/09/15.
//  Copyright (c) 2015 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOAFHTTPRequestOperationManager+Synchronous.h"

@implementation VAOAFHTTPRequestOperationManager (Synchronous)
- (id)synchronouslyPerformMethod:(NSString *)method
                       URLString:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                         timeout: (NSTimeInterval)timeout
                       operation:(VAOAFHTTPRequestOperation *__autoreleasing *)operationPtr
                           error:(NSError *__autoreleasing *)outError {

    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    [request setTimeoutInterval:timeout];
    
    VAOAFHTTPRequestOperation *op = [self HTTPRequestOperationWithRequest:request
                                                               success:nil
                                                               failure:nil];
    
    [op start];
    [op waitUntilFinished];
    
    if (operationPtr != nil) *operationPtr = op;
    
    // Must call responseObject before checking the error
    id responseObject = [op responseObject];
    if (outError != nil) *outError = [op error];
    
    return responseObject;
}

- (id)syncGET:(NSString *)URLString
   parameters:(NSDictionary *)parameters
    operation:(VAOAFHTTPRequestOperation *__autoreleasing *)operationPtr
        error:(NSError *__autoreleasing *)outError
{
    return [self synchronouslyPerformMethod:@"GET" URLString:URLString parameters:parameters timeout: 2.0 operation:operationPtr error:outError];
}

- (id)syncronousGET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            timeout: (NSTimeInterval)timeout
              error:(NSError *__autoreleasing *)outError {

    return [self synchronouslyPerformMethod:@"GET" URLString:URLString parameters:parameters timeout:timeout operation:nil error:outError];
}

@end
