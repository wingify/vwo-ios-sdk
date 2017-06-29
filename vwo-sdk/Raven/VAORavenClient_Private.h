//
//  RavenClient_Private.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAORavenClient.h"
#import "VAORavenConfig.h"

@interface VAORavenClient ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) VAORavenConfig *config;

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
