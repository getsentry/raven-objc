//
//  RavenTests.h
//  RavenTests
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RavenClient_Private.h"


@interface MockRavenClient : RavenClient

@property NSDictionary *lastEvent;
@property NSUInteger *numEvents;

@end


@interface RavenClientTest : SenTestCase

@property MockRavenClient *client;

@end
