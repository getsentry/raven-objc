//
//  RavenConfig.m
//  Raven
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "RavenConfig.h"

@implementation RavenConfig

- (BOOL)setDSN:(NSString *)DSN {
    NSURL *DSNURL = [NSURL URLWithString:DSN];
    
    NSMutableArray *pathComponents = [[DSNURL pathComponents] mutableCopy];
    if (![pathComponents count]) {
        NSLog(@"Missing path");
        return NO;
    }
    
    [pathComponents removeObjectAtIndex:0]; // always remove the first slash
    
    self.projectId = [pathComponents lastObject]; // project id is the last element of the path

    if (!self.projectId) {
        return NO;
    }
    
    [pathComponents removeLastObject]; // remove the project id...
    NSString *path = [pathComponents componentsJoinedByString:@"/"]; // ...and construct the path again
    
    // Add a slash to the end of the path if there is a path
    if (![path isEqualToString:@""]) {
        path = [path stringByAppendingString:@"/"];
    }
    
    NSNumber *port = [DSNURL port];
    if (!port) {
        if ([[DSNURL scheme] isEqualToString:@"https"]) {
            port = [NSNumber numberWithInteger:443];
        } else {
            port = [NSNumber numberWithInteger:80];
        }
    }
    
    self.serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@%@/api/%@/store/", [DSNURL scheme], [DSNURL host], port, path, self.projectId]];
    self.publicKey = [DSNURL user];
    self.secretKey = [DSNURL password];
    
    return YES;
}


@end

