//
//  RavenClient.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RavenCaptureMessage( s, ... ) [[RavenClient sharedClient] captureMessage:[NSString stringWithFormat:(s), ##__VA_ARGS__] level:kRavenLogLevelDebugInfo method:[NSString stringWithUTF8String:__FUNCTION__] file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__]

typedef enum {
    kRavenLogLevelDebug,
    kRavenLogLevelDebugInfo,
    kRavenLogLevelDebugWarning,
    kRavenLogLevelDebugError,
    kRavenLogLevelDebugFatal
} RavenLogLevel;


@interface RavenClient : NSObject <NSURLConnectionDelegate>

+ (RavenClient *)clientWithDSN:(NSString *)DSN;
+ (RavenClient *)sharedClient;

- (id)initWithDSN:(NSString *)DSN;
- (void)captureMessage:(NSString *)message;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level method:(NSString *)method file:(NSString *)file line:(NSInteger)line;
- (void)captureException:(NSException *)exception;

@end
