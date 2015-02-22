//
//  RavenClient.m
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <sys/utsname.h>
#import "RavenClient.h"
#import "RavenClient_Private.h"
#import "RavenConfig.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

NSString *const kRavenLogLevelArray[] = {
    @"debug",
    @"info",
    @"warning",
    @"error",
    @"fatal"
};

NSString *const userDefaultsKey = @"nl.mixedCase.RavenClient.Exceptions";
NSString *const sentryProtocol = @"4";
NSString *const sentryClient = @"raven-objc/0.5.0";

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

- (void)setTags:(NSDictionary *)tags {
    [self setTags:tags withDefaultValues:YES];
}

- (void)setTags:(NSDictionary *)tags withDefaultValues:(BOOL)withDefaultValues {
    NSMutableDictionary *mTags = [[NSMutableDictionary alloc] initWithDictionary:tags];

    if (withDefaultValues && ![mTags objectForKey:@"Build version"]) {
        NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        if (buildVersion) {
            [mTags setObject:buildVersion forKey:@"Build version"];
        }
    }

#if TARGET_OS_IPHONE
    if (withDefaultValues && ![mTags objectForKey:@"OS version"]) {
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        [mTags setObject:osVersion forKey:@"OS version"];
    }

    if (withDefaultValues && ![mTags objectForKey:@"Device model"]) {
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                                   encoding:NSUTF8StringEncoding];
        [mTags setObject:deviceModel forKey:@"Device model"];
    }
#endif

    _tags = mTags;
}

#pragma mark - Singleton and initializers

+ (RavenClient *)clientWithDSN:(NSString *)DSN {
    return [[self alloc] initWithDSN:DSN];
}

+ (RavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra {
    return [[self alloc] initWithDSN:DSN extra:extra];
}

+ (RavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags {
    return [[self alloc] initWithDSN:DSN extra:extra tags:tags];
}

+ (RavenClient *)clientWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags logger:(NSString *)logger {
    return [[self alloc] initWithDSN:DSN extra:extra tags:tags logger:logger];
}

+ (RavenClient *)sharedClient {
    return sharedClient;
}

+ (void)setSharedClient:(RavenClient *)client {
    sharedClient = client;
}

- (instancetype)initWithDSN:(NSString *)DSN {
    return [self initWithDSN:DSN extra:@{}];
}

- (instancetype)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra {
    return [self initWithDSN:DSN extra:extra tags:@{}];
}

- (instancetype)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags {
    return [self initWithDSN:DSN extra:extra tags:tags logger:nil];
}

- (instancetype)initWithDSN:(NSString *)DSN extra:(NSDictionary *)extra tags:(NSDictionary *)tags logger:(NSString *)logger {
    self = [super init];
    if (self) {
		_config = [[RavenConfig alloc] init];
        _extra = extra;
        _logger = logger;
        self.tags = tags;

        // Parse DSN
        if (![_config setDSN:DSN]) {
            NSLog(@"Invalid DSN %@!", DSN);
            return nil;
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

    [self captureMessage:message level:level additionalExtra:nil additionalTags:nil method:method file:file line:line];
}

- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level additionalExtra:(NSDictionary *)additionalExtra additionalTags:(NSDictionary *)additionalTags {
    [self captureMessage:message level:level additionalExtra:additionalExtra additionalTags:additionalTags method:nil file:nil line:0];
}

- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(NSDictionary *)additionalExtra
        additionalTags:(NSDictionary *)additionalTags
                method:(const char *)method
                  file:(const char *)file
                  line:(NSInteger)line {
    
    [self captureMessage:message level:level additionalExtra:additionalExtra additionalTags:additionalTags method:method file:file line:line sendNow:YES];
}

- (void)captureMessage:(NSString *)message
                 level:(RavenLogLevel)level
       additionalExtra:(NSDictionary *)additionalExtra
        additionalTags:(NSDictionary *)additionalTags
                method:(const char *)method
                  file:(const char *)file
                  line:(NSInteger)line
               sendNow:(BOOL)sendNow {
    
    NSArray *stacktrace;
    NSString *culprit;
    if (method && file && line) {
        NSString *filename = [[NSString stringWithUTF8String:file] lastPathComponent];
        NSString *methodString = [NSString stringWithUTF8String:method];
        NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:
                               filename, @"filename",
                               methodString, @"function",
                               [NSNumber numberWithInteger:line], @"lineno",
                               nil];
        
        stacktrace = [NSArray arrayWithObject:frame];

        culprit = [NSString stringWithFormat:@"%@ / %@", filename, methodString];
    }
    
    NSDictionary *data = [self prepareDictionaryForMessage:message
                                                     level:level
                                           additionalExtra:additionalExtra
                                            additionalTags:additionalTags
                                                   culprit:culprit
                                                stacktrace:stacktrace
                                                 exception:nil];
    
    if (!sendNow) {
        // We can't send this message to Sentry now, e.g. because the error was network related and the user may not have a data connection So, save it into NSUserDefaults.
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

#pragma mark - Exceptions

- (void)captureException:(NSException *)exception {
    [self captureException:exception sendNow:YES];
}

- (void)captureException:(NSException *)exception sendNow:(BOOL)sendNow {
   [self captureException:exception additionalExtra:nil additionalTags:nil sendNow:sendNow];
}

- (void)captureException:(NSException *)exception additionalExtra:(NSDictionary *)additionalExtra additionalTags:(NSDictionary *)additionalTags sendNow:(BOOL)sendNow {
    NSString *message = [NSString stringWithFormat:@"%@: %@", exception.name, exception.reason];

    NSDictionary *exceptionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   exception.name, @"type",
                                   exception.reason, @"value",
                                   nil];

    NSArray *callStack = [exception callStackSymbols];
    NSMutableArray *stacktrace = [[NSMutableArray alloc] initWithCapacity:[callStack count]];
    for (NSString *call in callStack) {
        [stacktrace addObject:[NSDictionary dictionaryWithObjectsAndKeys:call, @"function", nil]];
    }

    NSDictionary *data = [self prepareDictionaryForMessage:message
                                                     level:kRavenLogLevelDebugFatal
                                           additionalExtra:additionalExtra
                                            additionalTags:additionalTags
                                                   culprit:nil
                                                stacktrace:stacktrace
                                                 exception:exceptionDict];

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

- (void)captureException:(NSException *)exception method:(const char *)method file:(const char *)file line:(NSInteger)line sendNow:(BOOL)sendNow {
    NSString *message = [NSString stringWithFormat:@"%@: %@", exception.name, exception.reason];

    NSDictionary *exceptionDict = [NSDictionary dictionaryWithObjectsAndKeys:
            exception.name, @"type",
            exception.reason, @"value",
                    nil];

    NSArray *callStack = [exception callStackSymbols];
    NSMutableArray *stacktrace;
    if (method && file && line) {
        NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:
                [[NSString stringWithUTF8String:file] lastPathComponent], @"filename",
                [NSString stringWithUTF8String:method], @"function",
                [NSNumber numberWithInteger:line], @"lineno",
                        nil];

        stacktrace = [NSMutableArray arrayWithObject:frame];
    }
    for (NSString *call in callStack) {
        [stacktrace addObject:[NSDictionary dictionaryWithObjectsAndKeys:call, @"function", nil]];
    }

    NSDictionary *data = [self prepareDictionaryForMessage:message
                                                     level:kRavenLogLevelDebugFatal
                                           additionalExtra:nil
                                            additionalTags:nil
                                                   culprit:nil
                                                stacktrace:stacktrace
                                                 exception:exceptionDict];

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

- (NSDictionary *)prepareDictionaryForMessage:(NSString *)message
                                        level:(RavenLogLevel)level
                              additionalExtra:(NSDictionary *)additionalExtra
                               additionalTags:(NSDictionary *)additionalTags
                                      culprit:(NSString *)culprit
                                   stacktrace:(NSArray *)stacktrace
                                    exception:(NSDictionary *)exceptionDict {
    NSDictionary *stacktraceDict = [NSDictionary dictionaryWithObjectsAndKeys:stacktrace, @"frames", nil];

    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:self.extra];
    if (additionalExtra.count) {
        [extra addEntriesFromDictionary:additionalExtra];
    }

    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary:self.tags];
    if (additionalTags.count) {
        [tags addEntriesFromDictionary:additionalTags];
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self generateUUID], @"event_id",
            self.config.projectId, @"project",
            [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
            kRavenLogLevelArray[level], @"level",
            @"objc", @"platform",
            self.user ?: @"", @"user",

            extra, @"extra",
            tags, @"tags",
            self.logger ?: @"", @"logger",
            
            message, @"message",
            culprit ?: @"", @"culprit",
            stacktraceDict, @"stacktrace",
            exceptionDict, @"exception",
            nil];
}

- (void)sendDictionary:(NSDictionary *)dict {
    NSData *JSON = [self encodeJSON:dict];
    [self sendJSON:JSON];
}

- (void)sendJSON:(NSData *)JSON {
    NSString *header = [NSString stringWithFormat:@"Sentry sentry_version=%@, sentry_client=%@, sentry_timestamp=%ld, sentry_key=%@, sentry_secret=%@",
                        sentryProtocol,
                        sentryClient,
                        (long)[NSDate timeIntervalSinceReferenceDate],
                        self.config.publicKey,
                        self.config.secretKey];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.config.serverURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[JSON length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:JSON];
    [request setValue:header forHTTPHeaderField:@"X-Sentry-Auth"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
        	NSLog(@"JSON sent to Sentry");
        } else {
             NSLog(@"Connection failed! Error - %@ %@", [connectionError localizedDescription], [[connectionError userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        }
    }];
}

#pragma mark - JSON helpers

- (NSData *)encodeJSON:(id)obj {
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    return data;
}

@end
