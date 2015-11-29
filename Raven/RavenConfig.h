//
//  RavenConfig.h
//  Raven
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RavenConfig : NSObject

- (BOOL)setDSN:(NSString *)DSN;

@property (strong, nonatomic, nullable) NSURL *serverURL;
@property (strong, nonatomic, nullable) NSString *publicKey;
@property (strong, nonatomic, nullable) NSString *secretKey;
@property (strong, nonatomic, nullable) NSString *projectId;

@end

NS_ASSUME_NONNULL_END
