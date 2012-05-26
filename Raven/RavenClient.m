//
//  RavenClient.m
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenClient.h"
#import "RavenJSONUtilities.h"

NSString * const kRavenLogLevelArray[] = {
    @"debug",
    @"info",
    @"warning",
    @"error",
    @"fatal"
};

static RavenClient *sharedClient = nil;


@interface RavenClient ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSURL *serverURL;
@property (strong, nonatomic) NSString *publicKey;
@property (strong, nonatomic) NSString *secretKey;
@property (strong, nonatomic) NSString *projectId;
@property (strong, nonatomic) NSMutableData *receivedData;

- (BOOL)parseDSN:(NSString *)DSN;
- (NSString *)generateUUID;
- (void)sendDictionary:(NSDictionary *)dict;
- (void)sendJSON:(NSData *)JSON;

@end


@implementation RavenClient

@synthesize dateFormatter = _dateFormatter;
@synthesize serverURL = _serverURL;
@synthesize publicKey = _publicKey;
@synthesize secretKey = _secretKey;
@synthesize projectId = _projectId;
@synthesize receivedData = _receivedData;

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

#pragma mark - Public methods

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
        // Parse DSN
        if (![self parseDSN:DSN]) {
            NSLog(@"Invalid DSN!");
            return nil;
        }

        // Save singleton
        if (sharedClient == nil) {
            sharedClient = self;
        }
    }

    return self;
}

- (void)captureMessage:(NSString *)message {
    [self captureMessage:message level:kRavenLogLevelDebugInfo];
}

- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level {
    [self captureMessage:message level:level method:nil file:nil line:0];
}

- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level method:(NSString *)method file:(NSString *)file line:(NSInteger)line {
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [[self generateUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""], @"event_id",
                          self.projectId, @"project",
                          [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                          message, @"message",
                          kRavenLogLevelArray[level], @"level",
                          nil];

    if (file) {
        [data setObject:file forKey:@"culprit"];
    }
    
    if (method && file && line) {
        NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:
                               file, @"filename", 
                               method, @"function", 
                               [NSNumber numberWithInt:line], @"lineno", 
                               nil];
        
        NSDictionary *stacktrace = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSArray arrayWithObject:frame], @"frames", 
                      nil];

        [data setObject:stacktrace forKey:@"sentry.interfaces.Stacktrace"];    
    }

    [self sendDictionary:data];
}

- (void)captureException:(NSException *)exception {
}

#pragma mark - Private methods

- (BOOL)parseDSN:(NSString *)DSN {
    NSURL *DSNURL = [NSURL URLWithString:DSN];
    
    NSMutableArray *pathComponents = [[DSNURL pathComponents] mutableCopy];
    if (![pathComponents count]) {
        return NO;
    }
    
    [pathComponents removeObjectAtIndex:0]; // always remove the first slash
    
    self.projectId = [pathComponents lastObject]; // project id is the last element of the path
    if (!self.projectId) {
        return NO;
    }
    
    [pathComponents removeLastObject]; // remove the project id...
    NSString *path = [pathComponents componentsJoinedByString:@"/"]; // ...and construct the path again
    
    // Add a slash to the end of the path if there is a path
    if (![path isEqualToString:@""]) {
        path = [path stringByAppendingString:@"/"];
    }
    
    NSNumber *port = [DSNURL port];
    if (!port) {
        port = [NSNumber numberWithInteger:80];
    }
    
    self.serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@api/store/", [DSNURL scheme], [DSNURL host], path]];
    self.publicKey = [DSNURL user];
    self.secretKey = [DSNURL password];
    
    return YES;
}

- (NSString *)generateUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void)sendDictionary:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *JSON = JSONEncode(dict, &error);
    [self sendJSON:JSON];
}

- (void)sendJSON:(NSData *)JSON {
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *header = [NSString stringWithFormat:@"Sentry sentry_version=2.0, sentry_client=raven-objc/0.1, sentry_timestamp=%f, sentry_key=%@", timestamp, self.publicKey];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.serverURL];
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
    NSLog(@"Connection finished: %@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
}

@end
