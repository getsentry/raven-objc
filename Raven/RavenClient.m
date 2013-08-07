//
//  RavenClient.m
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenClient.h"
#import "RavenClient_Private.h"
#import "RavenConfig.h"
#import "RavenJSONUtilities.h"

NSString *const kRavenLogLevelArray[] = {
    @"debug",
    @"info",
    @"warning",
    @"error",
    @"fatal"
};

NSString *const userDefaultsKey = @"nl.mixedCase.RavenClient.Exceptions";

static RavenClient *sharedClient = nil;

@implementation RavenClient

void exceptionHandler(NSException *exception) {
	[[RavenClient sharedClient] captureException:exception sendNow:NO];
}

#pragma mark - Setters and getters

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:timeZone];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }

    return _dateFormatter;
}

#pragma mark - Singleton and initializers

+ (RavenClient *)clientWithDSN:(NSString *)DSN {
    RavenClient *client = [[self alloc] initWithDSN:DSN];
    return client;
}

+ (RavenClient *)sharedClient {
    return sharedClient;
}

- (id)initWithDSN:(NSString *)DSN {
    self = [super init];
    if (self) {
        self.config = [[RavenConfig alloc] init];
        
        // Parse DSN
        if (![self.config setDSN:DSN]) {
            NSLog(@"Invalid DSN %@!", DSN);
            return nil;
        }

        // Save singleton
        if (sharedClient == nil) {
            sharedClient = self;
        }
    }

    return self;
}

#pragma mark - Messages

- (void)captureMessage:(NSString *)message {
    [self captureMessage:message level:kRavenLogLevelDebugInfo];
}

- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level {
    [self captureMessage:message level:level method:nil file:nil line:0];
}

- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level method:(const char *)method file:(const char *)file line:(NSInteger)line {
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [self generateUUID], @"event_id",
                          self.config.projectId, @"project",
                          [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                          message, @"message",
                          kRavenLogLevelArray[level], @"level",
                          @"objc", @"platform",
                          nil];

    
    if (file) {
        [data setObject:[[NSString stringWithUTF8String:file] lastPathComponent] forKey:@"culprit"];
    }

    if (method && file && line) {
        NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:
                               [[NSString stringWithUTF8String:file] lastPathComponent], @"filename", 
                               [NSString stringWithUTF8String:method], @"function", 
                               [NSNumber numberWithInt:line], @"lineno", 
                               nil];

        NSDictionary *stacktrace = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSArray arrayWithObject:frame], @"frames", 
                      nil];

        [data setObject:stacktrace forKey:@"sentry.interfaces.Stacktrace"];
    }

    [self sendDictionary:data];
}

#pragma mark - Exceptions

- (void)captureException:(NSException *)exception {
    [self captureException:exception sendNow:YES];
}

- (void)captureException:(NSException *)exception sendNow:(BOOL)sendNow {
    NSString *message = [NSString stringWithFormat:@"%@: %@", exception.name, exception.reason];

    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [self generateUUID], @"event_id",
                                 self.config.projectId, @"project",
                                 [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                                 message, @"message",
                                 kRavenLogLevelArray[kRavenLogLevelDebugFatal], @"level",
                                 @"objc", @"platform",
                                 nil];

    NSDictionary *exceptionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   exception.name, @"type",
                                   exception.reason, @"value",
                                   nil];

    NSDictionary *extraDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [exception callStackSymbols], @"CallStack",
                                   nil];

    [data setObject:exceptionDict forKey:@"sentry.interfaces.Exception"];
    [data setObject:extraDict forKey:@"extra"];

    if (!sendNow) {
        // We can't send this exception to Sentry now, e.g. because the app is killed before the
        // connection can be made. So, save it into NSUserDefaults.
        NSArray *reports = [[NSUserDefaults standardUserDefaults] objectForKey:userDefaultsKey];
        if (reports != nil) {
            NSMutableArray *reportsCopy = [reports mutableCopy];
            [reportsCopy addObject:data];
            [[NSUserDefaults standardUserDefaults] setObject:reportsCopy forKey:userDefaultsKey];
        } else {
            reports = [NSArray arrayWithObject:data];
            [[NSUserDefaults standardUserDefaults] setObject:reports forKey:userDefaultsKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self sendDictionary:data];
    }
}

- (void)setupExceptionHandler {
    NSSetUncaughtExceptionHandler(&exceptionHandler);

    // Process saved crash reports
    NSArray *reports = [[NSUserDefaults standardUserDefaults] objectForKey:userDefaultsKey];
    if (reports != nil && [reports count]) {
        for (NSDictionary *data in reports) {
            [self sendDictionary:data];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:userDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Private methods

- (NSString *)generateUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *res = [(__bridge NSString *)string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(string);
    return res;
}

- (void)sendDictionary:(NSDictionary *)dict {
    NSError *error = nil;

    NSData *JSON = JSONEncode(dict, &error);
    [self sendJSON:JSON];
}

- (void)sendJSON:(NSData *)JSON {
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *header = [NSString stringWithFormat:@"Sentry sentry_version=2.0, sentry_client=raven-objc/0.1.0, sentry_timestamp=%f, sentry_key=%@", timestamp, self.config.publicKey];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.config.serverURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [JSON length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:JSON];
    [request setValue:header forHTTPHeaderField:@"X-Sentry-Auth"];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        self.receivedData = [NSMutableData data];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"JSON sent to Sentry");
}

@end
