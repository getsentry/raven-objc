//
//  RavenClient.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RavenCaptureMessage( s, ... ) [[RavenClient sharedClient] captureMessage:[NSString stringWithFormat:(s), ##__VA_ARGS__] level:kRavenLogLevelDebugInfo method:__FUNCTION__ file:__FILE__ line:__LINE__]

#define RavenCaptureError(error) [[RavenClient sharedClient] captureMessage:[NSString stringWithFormat:@"%@", error] \
                                                                      level:kRavenLogLevelDebugError \
                                                            additionalExtra:nil \
                                                             additionalTags:nil \
                                                                     method:__FUNCTION__ \
                                                                       file:__FILE__ \
                                                                       line:__LINE__];

#define RavenCaptureNetworkError(error) [[RavenClient sharedClient] captureMessage:[NSString stringWithFormat:@"%@", error] \
                                                                             level:kRavenLogLevelDebugError \
                                                                   additionalExtra:nil \
                                                                    additionalTags:nil \
                                                                            method:__FUNCTION__ \
                                                                              file:__FILE__ \
                                                                              line:__LINE__ \
                                                                           sendNow:NO];

#define RavenCaptureException(exception) [[RavenClient sharedClient] captureException:exception method:__FUNCTION__ file:__FILE__ line:__LINE__ sendNow:YES];

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kRavenLogLevelDebug,
    kRavenLogLevelDebugInfo,
    kRavenLogLevelDebugWarning,
    kRavenLogLevelDebugError,
    kRavenLogLevelDebugFatal
} RavenLogLevel;


@interface RavenClient : NSObject

@property (strong, nonatomic) NSDictionary *extra;
@property (strong, nonatomic) NSDictionary *tags;
@property (strong, nonatomic, nullable) NSString *logger;
@property (strong, nonatomic, nullable) NSDictionary *user;
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

- (void)setRelease:(nullable NSString *)release;

// Singleton and initializers
+ (nullable RavenClient *)clientWithDSN:(nullable NSString *)DSN;
+ (nullable RavenClient *)clientWithDSN:(nullable NSString *)DSN extra:(NSDictionary *)extra;
+ (nullable RavenClient *)clientWithDSN:(nullable NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags;
+ (nullable RavenClient *)clientWithDSN:(nullable NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags logger:(nullable NSString *)logger;

+ (nullable instancetype)sharedClient;
+ (void)setSharedClient:(nullable RavenClient *)client;

- (nullable instancetype)initWithDSN:(nullable NSString *)DSN;
- (nullable instancetype)initWithDSN:(nullable NSString *)DSN extra:(NSDictionary *)extra;
- (nullable instancetype)initWithDSN:(nullable NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags;
- (nullable instancetype)initWithDSN:(nullable NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags logger:(nullable NSString *)logger;

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
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level method:(nullable const char *)method file:(nullable const char *)file line:(NSInteger)line;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level additionalExtra:(nullable NSDictionary *)additionalExtra additionalTags:(nullable NSDictionary *)additionalTags;

- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(nullable NSDictionary *)additionalExtra
        additionalTags:(nullable NSDictionary *)additionalTags
                method:(nullable const char *)method
                  file:(nullable const char *)file
                  line:(NSInteger)line;

- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(nullable NSDictionary *)additionalExtra
        additionalTags:(nullable NSDictionary *)additionalTags
                method:(nullable const char *)method
                  file:(nullable const char *)file
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
- (void)captureException:(NSException *)exception additionalExtra:(nullable NSDictionary *)additionalExtra additionalTags:(nullable NSDictionary *)additionalTags sendNow:(BOOL)sendNow;
- (void)captureException:(NSException*)exception method:(nullable const char*)method file:(nullable const char*)file line:(NSInteger)line sendNow:(BOOL)sendNow;
- (void)setupExceptionHandler;

@end

NS_ASSUME_NONNULL_END
