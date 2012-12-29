//
//  RavenConfigTest.m
//  Raven
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenConfigTest.h"
#import "RavenConfig.h"

@implementation RavenConfigTest

- (void)testSetDSNWithPort
{
    RavenConfig *config = [RavenConfig alloc];
    BOOL didParse = [config setDSN:@"http://public_key:secret_key@example.com:8000/project-id"];
    
    STAssertTrue(didParse, @"Failed to parse DSN");
    
    STAssertTrue([config.publicKey isEqualToString:@"public_key"], @"Got incorrect publicKey %@", config.publicKey);
    STAssertTrue([config.secretKey isEqualToString:@"secret_key"], @"Got incorrect secretKey %@", config.secretKey);
    STAssertTrue([config.projectId isEqualToString:@"project-id"], @"Got incorrect projectId %@", config.projectId);
    
    NSURL *expectedURL = [NSURL URLWithString:@"http://example.com:8000/project-id/api/store/"];
    
    STAssertEquals(config.serverURL, expectedURL, @"Got incorrect serverURL %@", [config.serverURL absoluteString]);
}

@end
