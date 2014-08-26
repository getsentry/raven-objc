//
//  RavenClientTests.m
//  RavenClientTests
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenClientTest.h"

NSString *const testDSN = @"http://public:secret@example.com/foo";

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

    self.client = [[MockRavenClient alloc] initWithDSN:testDSN];
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
    STAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    STAssertEquals([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    STAssertEquals([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    STAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
    STAssertEquals([lastEvent valueForKey:@"platform"], @"objc",
                   @"Invalid value for platform: %@", [lastEvent valueForKey:@"platform"]);
}


- (void)testCaptureMessageWithMessageAndLevelAndMethodAndFileAndLine
{
    [self.client captureMessage:@"An example message" level:kRavenLogLevelDebugWarning
                         method:"method name" file:"filename" line:34];
    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    STAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    STAssertTrue([keys containsObject:@"message"], @"Missing message");
    STAssertTrue([keys containsObject:@"project"], @"Missing project");
    STAssertTrue([keys containsObject:@"level"], @"Missing level");
    STAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    STAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    STAssertTrue([keys containsObject:@"stacktrace"], @"Missing stacktrace");
    STAssertEquals([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    STAssertEquals([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    STAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
    STAssertEquals([lastEvent valueForKey:@"platform"], @"objc",
                   @"Invalid value for platform: %@", [lastEvent valueForKey:@"platform"]);
}

- (void)testCaptureMessageWithMessageAndLevelAndExtraAndTags
{
    [self.client captureMessage:@"An example message"
                          level:kRavenLogLevelDebugWarning
                additionalExtra:@{@"key" : @"extra value"}
                 additionalTags:@{@"key" : @"tag value"}];

    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    STAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    STAssertTrue([keys containsObject:@"message"], @"Missing message");
    STAssertTrue([keys containsObject:@"project"], @"Missing project");
    STAssertTrue([keys containsObject:@"level"], @"Missing level");
    STAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    STAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    STAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    STAssertTrue([keys containsObject:@"tags"], @"Missing tags");

    STAssertEquals([[lastEvent objectForKey:@"extra"] objectForKey:@"key"], @"extra value", @"Missing extra data");
    STAssertEquals([[lastEvent objectForKey:@"tags"] objectForKey:@"key"], @"tag value", @"Missing tags data");

    STAssertEquals([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    STAssertEquals([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    STAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
    STAssertEquals([lastEvent valueForKey:@"platform"], @"objc",
                   @"Invalid value for platform: %@", [lastEvent valueForKey:@"platform"]);
}

- (void)testClientWithExtraAndTags
{
    NSDictionary *extra = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];
    NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];

    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN extra:extra tags:tags];
    [client captureMessage:@"An example message"
                     level:kRavenLogLevelDebugWarning
           additionalExtra:@{@"key2" : @"extra value"}
            additionalTags:@{@"key2" : @"tag value"}];

    NSDictionary *lastEvent = client.lastEvent;
    NSArray *keys = [lastEvent allKeys];

    STAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    STAssertTrue([keys containsObject:@"tags"], @"Missing tags");
    STAssertEquals([[lastEvent objectForKey:@"extra"] objectForKey:@"key"], @"value", @"Missing extra data");
    STAssertEquals([[lastEvent objectForKey:@"tags"] objectForKey:@"key"], @"value", @"Missing tags data");

    STAssertEquals([[lastEvent objectForKey:@"extra"] objectForKey:@"key2"], @"extra value", @"Missing extra data");
    STAssertEquals([[lastEvent objectForKey:@"tags"] objectForKey:@"key2"], @"tag value", @"Missing tags data");

    STAssertNotNil([[lastEvent objectForKey:@"tags"] objectForKey:@"OS version"], @"Missing tags data");
    STAssertNotNil([[lastEvent objectForKey:@"tags"] objectForKey:@"Device model"], @"Missing tags data");
}

- (void)testClientWithRewritingExtraAndTags
{
    NSDictionary *extra = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];
    NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];

    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN extra:extra tags:tags];
    [client captureMessage:@"An example message"
                     level:kRavenLogLevelDebugWarning
           additionalExtra:@{@"key" : @"extra value"}
            additionalTags:@{@"key" : @"tag value"}];

    NSDictionary *lastEvent = client.lastEvent;
    NSArray *keys = [lastEvent allKeys];

    STAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    STAssertTrue([keys containsObject:@"tags"], @"Missing tags");

    STAssertEquals([[lastEvent objectForKey:@"extra"] objectForKey:@"key"], @"extra value", @"Missing extra data");
    STAssertEquals([[lastEvent objectForKey:@"tags"] objectForKey:@"key"], @"tag value", @"Missing tags data");
}

- (void)testClientWithLogger
{
    NSDictionary *extra = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];
    NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];
    NSString *logger = @"Logger value";
    
    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN extra:extra tags:tags logger:logger];
    [client captureMessage:@"An example message"];
    
    NSDictionary *lastEvent = client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    
    STAssertEquals([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    STAssertEquals([lastEvent valueForKey:@"logger"], @"Logger value",
                   @"Invalid value for logger: %@", [lastEvent valueForKey:@"logger"]);

}

@end
