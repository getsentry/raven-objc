//
//  RavenClientTests.m
//  RavenClientTests
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenTests.h"
#import "RavenClient_Private.h"

@implementation RavenTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testParseDSNWithPort
{
    RavenClient *client = [RavenClient alloc];
    BOOL didParse = [client parseDSN:@"http://public_key:secret_key@example.com:8000/project-id"];
    
    STAssertTrue(didParse, @"Failed to parse DSN");
    
    STAssertTrue([client.publicKey isEqualToString:@"public_key"], @"Got incorrect publicKey %@", client.publicKey);
    STAssertTrue([client.secretKey isEqualToString:@"secret_key"], @"Got incorrect secretKey %@", client.secretKey);
    STAssertTrue([client.projectId isEqualToString:@"project-id"], @"Got incorrect projectId %@", client.projectId);
    
    NSURL *expectedURL = [NSURL URLWithString:@"http://example.com:8000/project-id/api/store/"];
    
    STAssertEquals(client.serverURL, expectedURL, @"Got incorrect serverURL %@", [client.serverURL absoluteString]);
}

@end
