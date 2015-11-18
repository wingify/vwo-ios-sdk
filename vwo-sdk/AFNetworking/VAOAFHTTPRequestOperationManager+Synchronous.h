//
//  VAOAFHTTPRequestOperationManager+Synchronous.h
//  VWO
//
//  Created by Swapnil on 29/09/15.
//  Copyright (c) 2015 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOAFHTTPRequestOperationManager.h"

@interface VAOAFHTTPRequestOperationManager (Synchronous)
- (id)syncGET:(NSString *)path
   parameters:(NSDictionary *)parameters
    operation:(VAOAFHTTPRequestOperation *__autoreleasing *)operationPtr
        error:(NSError *__autoreleasing *)outError;
/*
- (id)syncPOST:(NSString *)path
    parameters:(NSDictionary *)parameters
     operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
         error:(NSError *__autoreleasing *) outError;

- (id)syncPUT:(NSString *)path
   parameters:(NSDictionary *)parameters
    operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
        error:(NSError *__autoreleasing *) outError;

- (id)syncDELETE:(NSString *)path
      parameters:(NSDictionary *)parameters
       operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
           error:(NSError *__autoreleasing *) outError;

- (id)syncPATCH:(NSString *)path
     parameters:(NSDictionary *)parameters
      operation:(VAOAFHTTPRequestOperation *__autoreleasing *) operationPtr
          error:(NSError *__autoreleasing *) outError;

- (id)synchronouslyPerformMethod:(NSString *)method
                       URLString:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                       operation:(VAOAFHTTPRequestOperation *__autoreleasing *)operationPtr
                           error:(NSError *__autoreleasing *)outError;

*/
@end
