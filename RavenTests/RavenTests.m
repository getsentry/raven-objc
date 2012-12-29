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

- (void)testGenerateUUID
{
    RavenClient *client = [RavenClient alloc];
    NSString *uuid = [client generateUUID];
    STAssertEquals([uuid length], (NSUInteger)32, @"Invalid value for UUID returned: %@", uuid);
}

@end
