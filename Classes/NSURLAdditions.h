//
//  NSURLAdditions.h
//  iRedmine
//
//  Created by Thomas Stägemann on 30.05.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (NSURLAdditions)

- (NSString*)stringByResolvingPathAndRemoveAuthentication;

@end
