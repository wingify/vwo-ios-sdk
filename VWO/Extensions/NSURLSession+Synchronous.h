//
//  NSURLSession+Synchronous.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 19/09/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (Synchronous)

- (nullable NSData *)sendSynchronousDataTaskWithURL:(nonnull NSURL *)url
                                  returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                                              error:(NSError *_Nullable*_Nullable)error;

- (nullable NSData *)sendSynchronousDataTaskWithRequest:(nonnull NSURLRequest *)request
                                      returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                                                  error:(NSError *_Nullable*_Nullable)error;

@end

NS_ASSUME_NONNULL_END
