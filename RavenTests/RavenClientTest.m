//
//  RavenClientTests.m
//  RavenClientTests
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenClientTest.h"

@implementation MockRavenClient

- (void)sendDictionary:(NSDictionary *)dict
{
    self.lastEvent = dict;
    self.numEvents += 1;
}

@end

@implementation RavenClientTest

- (void)setUp
{
    [super setUp];

    self.client = [[MockRavenClient alloc] initWithDSN:@"http://public:secret@example.com/foo"];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGenerateUUID
{
    NSString *uuid = [self.client generateUUID];
    STAssertEquals([uuid length], (NSUInteger)32, @"Invalid value for UUID returned: %@", uuid);
}

- (void)testCaptureMessage
{
    [self.client captureMessage:@"An example message"];
    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    STAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    STAssertTrue([keys containsObject:@"message"], @"Missing message: %@", lastEvent);
    STAssertEquals([lastEvent valueForKey:@"message"], @"An example message",
                 @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
}

@end
