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

- (id)syncronousGET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            timeout: (NSTimeInterval)timeout
              error:(NSError *__autoreleasing *)outError;

@end
