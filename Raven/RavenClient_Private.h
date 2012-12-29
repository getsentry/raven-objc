//
//  RavenClient_Private.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RavenClient.h"
#import "RavenConfig.h"

@interface RavenClient ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) RavenConfig *config;

- (NSString *)generateUUID;
- (void)sendDictionary:(NSDictionary *)dict;
- (void)sendJSON:(NSData *)JSON;

@end
