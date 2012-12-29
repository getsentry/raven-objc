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

- (void)testCaptureMessageWithOnlyMessage
{
    [self.client captureMessage:@"An example message"];
    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    STAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    STAssertTrue([keys containsObject:@"message"], @"Missing message");
    STAssertTrue([keys containsObject:@"project"], @"Missing project");
    STAssertTrue([keys containsObject:@"level"], @"Missing level");
    STAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    STAssertEquals([lastEvent valueForKey:@"message"], @"An example message",
                 @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    STAssertEquals([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    STAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"info"],
                   @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
}

- (void)testCaptureMessageWithMessageAndLevel
{
    [self.client captureMessage:@"An example message" level:kRavenLogLevelDebugWarning];
    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    STAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    STAssertTrue([keys containsObject:@"message"], @"Missing message");
    STAssertTrue([keys containsObject:@"project"], @"Missing project");
    STAssertTrue([keys containsObject:@"level"], @"Missing level");
    STAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    STAssertEquals([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    STAssertEquals([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    STAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
}

@end
