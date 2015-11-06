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
    
    XCTAssertTrue(didParse, @"Failed to parse DSN");
    
    XCTAssertTrue([config.publicKey isEqualToString:@"public_key"], @"Got incorrect publicKey %@", config.publicKey);
    XCTAssertTrue([config.secretKey isEqualToString:@"secret_key"], @"Got incorrect secretKey %@", config.secretKey);
    XCTAssertTrue([config.projectId isEqualToString:@"project-id"], @"Got incorrect projectId %@", config.projectId);
    
    NSString *expectedURL = @"http://example.com:8000/api/project-id/store/";
    
    XCTAssertTrue([[config.serverURL absoluteString] isEqualToString:expectedURL], @"Got incorrect serverURL %@", [config.serverURL absoluteString]);
}

- (void)testSetDSNWithSSLPortUndefined
{
    RavenConfig *config = [RavenConfig alloc];
    BOOL didParse = [config setDSN:@"https://public_key:secret_key@example.com/project-id"];
    
    XCTAssertTrue(didParse, @"Failed to parse DSN");
    
    XCTAssertTrue([config.publicKey isEqualToString:@"public_key"], @"Got incorrect publicKey %@", config.publicKey);
    XCTAssertTrue([config.secretKey isEqualToString:@"secret_key"], @"Got incorrect secretKey %@", config.secretKey);
    XCTAssertTrue([config.projectId isEqualToString:@"project-id"], @"Got incorrect projectId %@", config.projectId);
    
    NSString *expectedURL = @"https://example.com:443/api/project-id/store/";
    
    XCTAssertTrue([[config.serverURL absoluteString] isEqualToString:expectedURL], @"Got incorrect serverURL %@", [config.serverURL absoluteString]);
}

- (void)testSetDSNWithoutSSLPortUndefined
{
    RavenConfig *config = [RavenConfig alloc];
    BOOL didParse = [config setDSN:@"http://public_key:secret_key@example.com/project-id"];
    
    XCTAssertTrue(didParse, @"Failed to parse DSN");
    
    XCTAssertTrue([config.publicKey isEqualToString:@"public_key"], @"Got incorrect publicKey %@", config.publicKey);
    XCTAssertTrue([config.secretKey isEqualToString:@"secret_key"], @"Got incorrect secretKey %@", config.secretKey);
    XCTAssertTrue([config.projectId isEqualToString:@"project-id"], @"Got incorrect projectId %@", config.projectId);
    
    NSString *expectedURL = @"http://example.com:80/api/project-id/store/";
    
    XCTAssertTrue([[config.serverURL absoluteString] isEqualToString:expectedURL], @"Got incorrect serverURL %@", [config.serverURL absoluteString]);
}


@end
