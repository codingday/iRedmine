//
//  NSURLRequestAdditions.m
//  iRedmine
//
//  Created by Thomas Stägemann on 21.09.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "NSURLRequestAdditions.h"


@implementation NSURLRequest (NSURLRequestAdditions)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host {
	return YES;
}

@end
