//
//  VAOAFHTTPRequestOperationManager+Synchronous.h
//  VWO
//
//  Created by Swapnil on 29/09/15.
//  Copyright (c) 2015 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOAFHTTPRequestOperationManager.h"

@interface VAOAFHTTPRequestOperationManager (Synchronous)

- (id)synchronousGET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            timeout: (NSTimeInterval)timeout
              error:(NSError *__autoreleasing *)outError;

@end
