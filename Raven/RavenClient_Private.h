//
//  RavenClient_Private.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RavenClient : NSObject <NSURLConnectionDelegate>

- (BOOL)parseDSN:(NSString *)DSN;

@property (strong, nonatomic) NSURL *serverURL;
@property (strong, nonatomic) NSString *publicKey;
@property (strong, nonatomic) NSString *secretKey;
@property (strong, nonatomic) NSString *projectId;

@end
