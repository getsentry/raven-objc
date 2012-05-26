//
//  RavenClient.m
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenClient.h"
#import "RavenJSONUtilities.h"

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
- (void)sendJSON:(NSData *)JSON;

@end


@implementation RavenClient

@synthesize dateFormatter = _dateFormatter;
@synthesize serverURL = _serverURL;
@synthesize publicKey = _publicKey;
@synthesize secretKey = _secretKey;
@synthesize projectId = _projectId;
@synthesize receivedData = _receivedData;

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:timeZone];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    
    return _dateFormatter;
}

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

- (void)captureMessage:(NSString *)message {
//    "event_id": "fc6d8c0c43fc4630ad850ee518f1b9d0",
//    "project": "default",
//    "culprit": "my.module.function_name",
//    "timestamp": "2011-05-02T17:41:36",
//    "message": "SyntaxError: Wattttt!"
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [[self generateUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""], @"event_id",
                          self.projectId, @"project",
                          @"my.module.function_name", @"culprit",
                          [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                          message, @"message",
                          nil];

    NSError *error = nil;
    NSData *JSON = JSONEncode(data, &error);
    [self sendJSON:JSON];
}

- (void)captureException:(NSException *)exception {
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
