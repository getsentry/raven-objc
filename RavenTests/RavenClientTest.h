//
//  RavenTests.h
//  RavenTests
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RavenClient_Private.h"


@interface MockRavenClient : RavenClient

@property NSDictionary *lastEvent;
@property NSUInteger *numEvents;

@end


@interface RavenClientTest : XCTestCase

@property MockRavenClient *client;

@end
