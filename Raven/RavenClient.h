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

// Singleton and initializers
+ (RavenClient *)clientWithDSN:(NSString *)DSN;
+ (RavenClient *)sharedClient;

- (id)initWithDSN:(NSString *)DSN;

// Messages
- (void)captureMessage:(NSString *)message;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level method:(const char *)method file:(const char *)file line:(NSInteger)line;

// Exceptions
- (void)captureException:(NSException *)exception;
- (void)captureException:(NSException *)exception sendNow:(BOOL)sendNow;
- (void)setupExceptionHandler;

@end
