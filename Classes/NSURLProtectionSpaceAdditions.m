//
//  NSURLProtectionSpaceAdditions.m
//  iRedmine
//
//  Created by Thomas Stägemann on 25.05.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "NSURLProtectionSpaceAdditions.h"


@implementation NSURLProtectionSpace (NSURLProtectionSpaceAdditions)

+ (id)protectionSpaceWithURL:(NSURL*)URL {
	return [[[NSURLProtectionSpace alloc] initWithHost:[URL host] port:[[URL port] integerValue] protocol:[URL scheme] realm:[URL path] authenticationMethod:nil] autorelease];
}

@end
