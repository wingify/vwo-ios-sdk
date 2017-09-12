//
//  VWOAFHTTPRequestOperationManager+Synchronous.h
//  VWO
//
//  Created by Swapnil on 29/09/15.
//  Copyright (c) 2015 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWOAFHTTPRequestOperationManager.h"

@interface VWOAFHTTPRequestOperationManager (Synchronous)

- (id)synchronousGET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            timeout: (NSTimeInterval)timeout
              error:(NSError *__autoreleasing *)outError;

@end
