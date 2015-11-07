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
    XCTAssertEqual([uuid length], (NSUInteger)32, @"Invalid value for UUID returned: %@", uuid);
}

- (void)testCaptureMessageWithOnlyMessage
{
    [self.client captureMessage:@"An example message"];
    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    XCTAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    XCTAssertTrue([keys containsObject:@"message"], @"Missing message");
    XCTAssertTrue([keys containsObject:@"project"], @"Missing project");
    XCTAssertTrue([keys containsObject:@"level"], @"Missing level");
    XCTAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    XCTAssertEqual([lastEvent valueForKey:@"message"], @"An example message",
                 @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    XCTAssertEqual([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    XCTAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"info"],
                   @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
}

- (void)testCaptureMessageWithMessageAndLevel
{
    [self.client captureMessage:@"An example message" level:kRavenLogLevelDebugWarning];
    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    XCTAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    XCTAssertTrue([keys containsObject:@"message"], @"Missing message");
    XCTAssertTrue([keys containsObject:@"project"], @"Missing project");
    XCTAssertTrue([keys containsObject:@"level"], @"Missing level");
    XCTAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    XCTAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    XCTAssertEqual([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    XCTAssertEqual([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    XCTAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
    XCTAssertEqual([lastEvent valueForKey:@"platform"], @"objc",
                   @"Invalid value for platform: %@", [lastEvent valueForKey:@"platform"]);
}


- (void)testCaptureMessageWithMessageAndLevelAndMethodAndFileAndLine
{
    [self.client captureMessage:@"An example message" level:kRavenLogLevelDebugWarning
                         method:"method name" file:"filename" line:34];
    NSDictionary *lastEvent = self.client.lastEvent;
    NSArray *keys = [lastEvent allKeys];
    XCTAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    XCTAssertTrue([keys containsObject:@"message"], @"Missing message");
    XCTAssertTrue([keys containsObject:@"project"], @"Missing project");
    XCTAssertTrue([keys containsObject:@"level"], @"Missing level");
    XCTAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    XCTAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    XCTAssertTrue([keys containsObject:@"stacktrace"], @"Missing stacktrace");
    XCTAssertEqual([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    XCTAssertEqual([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    XCTAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
    XCTAssertEqual([lastEvent valueForKey:@"platform"], @"objc",
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
    XCTAssertTrue([keys containsObject:@"event_id"], @"Missing event_id");
    XCTAssertTrue([keys containsObject:@"message"], @"Missing message");
    XCTAssertTrue([keys containsObject:@"project"], @"Missing project");
    XCTAssertTrue([keys containsObject:@"level"], @"Missing level");
    XCTAssertTrue([keys containsObject:@"timestamp"], @"Missing timestamp");
    XCTAssertTrue([keys containsObject:@"platform"], @"Missing platform");
    XCTAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    XCTAssertTrue([keys containsObject:@"tags"], @"Missing tags");

    XCTAssertEqual([lastEvent[@"extra"] objectForKey:@"key"], @"extra value", @"Missing extra data");
    XCTAssertEqual([lastEvent[@"tags"] objectForKey:@"key"], @"tag value", @"Missing tags data");

    XCTAssertEqual([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    XCTAssertEqual([lastEvent valueForKey:@"project"], self.client.config.projectId,
                   @"Invalid value for project: %@", [lastEvent valueForKey:@"project"]);
    XCTAssertTrue([[lastEvent valueForKey:@"level"] isEqualToString:@"warning"],
                 @"Invalid value for level: %@", [lastEvent valueForKey:@"level"]);
    XCTAssertEqual([lastEvent valueForKey:@"platform"], @"objc",
                   @"Invalid value for platform: %@", [lastEvent valueForKey:@"platform"]);
}

- (void)testClientWithExtraAndTags
{
    NSDictionary *extra = @{@"key" : @"value"};
    NSDictionary *tags = @{@"key" : @"value"};

    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN extra:extra tags:tags];
    [client captureMessage:@"An example message"
                     level:kRavenLogLevelDebugWarning
           additionalExtra:@{@"key2" : @"extra value"}
            additionalTags:@{@"key2" : @"tag value"}];

    NSDictionary *lastEvent = client.lastEvent;
    NSArray *keys = [lastEvent allKeys];

    XCTAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    XCTAssertTrue([keys containsObject:@"tags"], @"Missing tags");
    XCTAssertEqual([lastEvent[@"extra"] objectForKey:@"key"], @"value", @"Missing extra data");
    XCTAssertEqual([lastEvent[@"tags"] objectForKey:@"key"], @"value", @"Missing tags data");

    XCTAssertEqual([lastEvent[@"extra"] objectForKey:@"key2"], @"extra value", @"Missing extra data");
    XCTAssertEqual([lastEvent[@"tags"] objectForKey:@"key2"], @"tag value", @"Missing tags data");

    XCTAssertNotNil([lastEvent[@"tags"] objectForKey:@"OS version"], @"Missing tags data");
    XCTAssertNotNil([lastEvent[@"tags"] objectForKey:@"Device model"], @"Missing tags data");
}

- (void)testClientWithRewritingExtraAndTags
{
    NSDictionary *extra = @{@"key" : @"value"};
    NSDictionary *tags = @{@"key" : @"value"};

    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN extra:extra tags:tags];
    [client captureMessage:@"An example message"
                     level:kRavenLogLevelDebugWarning
           additionalExtra:@{@"key" : @"extra value"}
            additionalTags:@{@"key" : @"tag value"}];

    NSDictionary *lastEvent = client.lastEvent;
    NSArray *keys = [lastEvent allKeys];

    XCTAssertTrue([keys containsObject:@"extra"], @"Missing extra");
    XCTAssertTrue([keys containsObject:@"tags"], @"Missing tags");

    XCTAssertEqual([lastEvent[@"extra"] objectForKey:@"key"], @"extra value", @"Missing extra data");
    XCTAssertEqual([lastEvent[@"tags"] objectForKey:@"key"], @"tag value", @"Missing tags data");
}

- (void)testClientWithLogger
{
    NSDictionary *extra = @{@"key" : @"value"};
    NSDictionary *tags = @{@"key" : @"value"};
    NSString *logger = @"Logger value";
    
    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN extra:extra tags:tags logger:logger];
    [client captureMessage:@"An example message"];
    
    NSDictionary *lastEvent = client.lastEvent;

    XCTAssertEqual([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
    XCTAssertEqual([lastEvent valueForKey:@"logger"], @"Logger value",
                   @"Invalid value for logger: %@", [lastEvent valueForKey:@"logger"]);

}

- (void)testClientWithUser
{
    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN];
    client.user = @{@"username" : @"timor", @"ip_address" : @"127.0.0.1"};
    [client captureMessage:@"An example message"];

    NSDictionary *lastEvent = client.lastEvent;

    NSArray *keys = [lastEvent allKeys];
    XCTAssertTrue([keys containsObject:@"user"], @"Missing user");

    XCTAssertEqual([lastEvent[@"user"] objectForKey:@"username"], @"timor", @"Missing username");
    XCTAssertEqual([lastEvent[@"user"] objectForKey:@"ip_address"], @"127.0.0.1", @"Missing ip address");

    XCTAssertEqual([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
}

- (void)testClientWithoutDSN
{
    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:nil];
    client.user = @{@"username" : @"timor", @"ip_address" : @"127.0.0.1"};
    
    [client captureMessage:@"An example message"];
    
    NSDictionary *lastEvent = client.lastEvent;
    
    NSArray *keys = [lastEvent allKeys];
    XCTAssertTrue([keys containsObject:@"user"], @"Missing user");
    
    XCTAssertEqual([lastEvent[@"user"] objectForKey:@"username"], @"timor", @"Missing username");
    XCTAssertEqual([lastEvent[@"user"] objectForKey:@"ip_address"], @"127.0.0.1", @"Missing ip address");
    
    XCTAssertEqual([lastEvent valueForKey:@"message"], @"An example message",
                   @"Invalid value for message: %@", [lastEvent valueForKey:@"message"]);
}

- (void)testClientWithEmptyRelease
{
    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN];
    [client captureMessage:@"An example message"];
    
    NSDictionary *lastEvent = client.lastEvent;
    
    XCTAssertEqual([lastEvent valueForKey:@"release"], @"",
                   @"Invalid value for release: %@", [lastEvent valueForKey:@"release"]);
    
}

- (void)testClientWithExplicitRelease
{
    MockRavenClient *client = [[MockRavenClient alloc] initWithDSN:testDSN];
    
    [client setRelease:@"1.0"];

    [client captureMessage:@"An example message"];
    
    NSDictionary *lastEvent = client.lastEvent;
    
    XCTAssertEqual([lastEvent valueForKey:@"release"], @"1.0",
                   @"Invalid value for release: %@", [lastEvent valueForKey:@"release"]);
    
}

@end
