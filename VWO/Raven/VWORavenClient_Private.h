//
//  RavenClient_Private.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWORavenClient.h"
#import "VWORavenConfig.h"

@interface VWORavenClient ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) VWORavenConfig *config;

- (NSDictionary *)prepareDictionaryForMessage:(NSString *)message
                                        level:(RavenLogLevel)level
                              additionalExtra:(NSDictionary *)additionalExtra
                               additionalTags:(NSDictionary *)additionalTags
                                      culprit:(NSString *)culprit
                                   stacktrace:(NSArray *)stacktrace
                                    exception:(NSDictionary *)exceptionDict;
- (void)sendDictionary:(NSDictionary *)dict;
- (void)sendJSON:(NSData *)JSON;

@end
