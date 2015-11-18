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
                       operation:(VAOAFHTTPRequestOperation *__autoreleasing *)operationPtr
                           error:(NSError *__autoreleasing *)outError {
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    [request setTimeoutInterval:2.0];
    
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
    return [self synchronouslyPerformMethod:@"GET" URLString:URLString parameters:parameters operation:operationPtr error:outError];
}

/*
- (id)syncPOST:(NSString *)URLString
    parameters:(NSDictionary *)parameters
     operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
         error:(NSError *__autoreleasing *) outError
{
    return [self synchronouslyPerformMethod:@"POST" URLString:URLString parameters:parameters operation:operationPtr error:outError];
}

- (id)syncPUT:(NSString *)URLString
   parameters:(NSDictionary *)parameters
    operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
        error:(NSError *__autoreleasing *) outError
{
    return [self synchronouslyPerformMethod:@"PUT" URLString:URLString parameters:parameters operation:operationPtr error:outError];
}

- (id)syncDELETE:(NSString *)URLString
      parameters:(NSDictionary *)parameters
       operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
           error:(NSError *__autoreleasing *) outError
{
    return [self synchronouslyPerformMethod:@"DELETE" URLString:URLString parameters:parameters operation:operationPtr error:outError];
}

- (id)syncPATCH:(NSString *)URLString
     parameters:(NSDictionary *)parameters
      operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
          error:(NSError *__autoreleasing *) outError
{
    return [self synchronouslyPerformMethod:@"PATCH" URLString:URLString parameters:parameters operation:operationPtr error:outError];
}
 */
@end
