//
//  NSURLAdditions.m
//  iRedmine
//
//  Created by Thomas Stägemann on 30.05.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "NSURLAdditions.h"


@implementation NSURL (NSURLAdditions)

- (NSString*)stringByResolvingPathAndRemoveAuthentication {
	NSMutableString * new = [NSMutableString stringWithFormat:@"%@://%@",[self scheme],[self host]];
	if ([self port])
		[new appendFormat:@":%@",[self port]];
	
	NSString * path = [NSString pathWithComponents:[[self path] pathComponents]];
	if ([path isEmptyOrWhitespace]) {
		[new appendString:@"/"];
		return new;
	}
	
	if (![path hasPrefix:@"/"]) 
		[new appendString:@"/"];
	[new appendString:path];
	if (![path hasSuffix:@"/"]) 
		[new appendString:@"/"];
	return new;
}

@end
