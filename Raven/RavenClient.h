//
//  RavenClient.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RavenCaptureMessage( s, ... ) [[RavenClient sharedClient] captureMessage:[NSString stringWithFormat:(s), ##__VA_ARGS__] level:kRavenLogLevelDebugInfo method:__FUNCTION__ file:__FILE__ line:__LINE__]

typedef enum {
    kRavenLogLevelDebug,
    kRavenLogLevelDebugInfo,
    kRavenLogLevelDebugWarning,
    kRavenLogLevelDebugError,
    kRavenLogLevelDebugFatal
} RavenLogLevel;


@interface RavenClient : NSObject <NSURLConnectionDelegate>

@property (strong, nonatomic) NSDictionary *extra;
@property (strong, nonatomic) NSDictionary *tags;

// Singleton and initializers
+ (RavenClient *)clientWithDSN:(NSString *)DSN;
+ (RavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra;
+ (RavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags;
+ (RavenClient *)sharedClient;

- (id)initWithDSN:(NSString *)DSN;
- (id)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra;
- (id)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags;

// Messages
- (void)captureMessage:(NSString *)message;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level method:(const char *)method file:(const char *)file line:(NSInteger)line;

// All entries from additionalExtra/additionalTags are added to extra/tags.
//
// If dictionaries contain the same key, the entries from extra/tags dictionaries will be replaced with entries
// from additionalExtra/additionalTags dictionaries.
- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(NSDictionary *)additionalExtra
        additionalTags:(NSDictionary *)additionalTags;

- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(NSDictionary *)additionalExtra
        additionalTags:(NSDictionary *)additionalTags
                method:(const char *)method
                  file:(const char *)file
                  line:(NSInteger)line;

// Exceptions
- (void)captureException:(NSException *)exception;
- (void)captureException:(NSException *)exception sendNow:(BOOL)sendNow;
- (void)setupExceptionHandler;

@end
