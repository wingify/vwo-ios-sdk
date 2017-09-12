//
//  RavenClient.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kRavenLogLevelDebug,
    kRavenLogLevelDebugInfo,
    kRavenLogLevelDebugWarning,
    kRavenLogLevelDebugError,
    kRavenLogLevelDebugFatal
} RavenLogLevel;


@interface VWORavenClient : NSObject

@property (strong, nonatomic) NSDictionary *extra;
@property (strong, nonatomic) NSDictionary *tags;
@property (strong, nonatomic) NSString *logger;
@property (strong, nonatomic) NSDictionary *user;
@property (assign, nonatomic) BOOL debugMode;

/**
 * By setting tags with setTags: selector it will also set default settings:
 * - Build version
 * - OS version (on iOS)
 * - Device model (on iOS)
 *
 * For full control use this method.
 */
- (void)setTags:(NSDictionary *)tags withDefaultValues:(BOOL)withDefaultValues;

// Singleton and initializers
+ (VWORavenClient *)clientWithDSN:(NSString *)DSN;
+ (VWORavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra;
+ (VWORavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags;
+ (VWORavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags logger:(NSString *)logger;

+ (instancetype)sharedClient;
+ (void)setSharedClient:(VWORavenClient *)client;

- (instancetype)initWithDSN:(NSString *)DSN;
- (instancetype)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra;
- (instancetype)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags;
- (instancetype)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags logger:(NSString *)logger;

/**
 * Messages
 *
 * All entries from additionalExtra/additionalTags are added to extra/tags.
 *
 * If dictionaries contain the same key, the entries from extra/tags dictionaries will be replaced with entries
 * from additionalExtra/additionalTags dictionaries.
 */
- (void)captureMessage:(NSString *)message;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level method:(const char *)method file:(const char *)file line:(NSInteger)line;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level additionalExtra:(NSDictionary *)additionalExtra additionalTags:(NSDictionary *)additionalTags;

- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(NSDictionary *)additionalExtra
        additionalTags:(NSDictionary *)additionalTags
                method:(const char *)method
                  file:(const char *)file
                  line:(NSInteger)line;

- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(NSDictionary *)additionalExtra
        additionalTags:(NSDictionary *)additionalTags
                method:(const char *)method
                  file:(const char *)file
                  line:(NSInteger)line
               sendNow:(BOOL)sendNow;

/**
 * Exceptions
 *
 * All entries from additionalExtra/additionalTags are added to extra/tags.
 *
 * If dictionaries contain the same key, the entries from extra/tags dictionaries will be replaced with entries
 * from additionalExtra/additionalTags dictionaries.
 */
- (void)captureException:(NSException *)exception;
- (void)captureException:(NSException *)exception sendNow:(BOOL)sendNow;
- (void)captureException:(NSException *)exception additionalExtra:(NSDictionary *)additionalExtra additionalTags:(NSDictionary *)additionalTags sendNow:(BOOL)sendNow;
- (void)captureException:(NSException*)exception method:(const char*)method file:(const char*)file line:(NSInteger)line sendNow:(BOOL)sendNow;
- (void)setupExceptionHandler;

@end
