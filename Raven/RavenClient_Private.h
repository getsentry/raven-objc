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
@property (strong, nonatomic) RavenConfig *config;

- (NSString *)generateUUID;
- (NSDictionary *)prepareDictionaryForMessage:(NSString *)message
                                        level:(RavenLogLevel)level
                              additionalExtra:(NSDictionary *)additionalExtra
                               additionalTags:(NSDictionary *)additionalTags
                                      culprit:(NSString *)culprit
                                   stacktrace:(NSArray *)stacktrace
                                    exception:(NSDictionary *)exceptionDict;
- (void)sendDictionary:(NSDictionary *)dict success:(void (^)(void))success error:(void (^)(NSError *))error;
- (void)sendJSON:(NSData *)JSON success:(void (^)(void))success error:(void (^)(NSError *err))error;

@end
