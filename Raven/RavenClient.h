//
//  RavenClient.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RavenClient : NSObject <NSURLConnectionDelegate>

+ (RavenClient *)clientWithDSN:(NSString *)DSN;
+ (RavenClient *)sharedClient;

- (id)initWithDSN:(NSString *)DSN;
- (void)captureMessage:(NSString *)message;
- (void)captureException:(NSException *)exception;

@end
