//
//  RESTRequest.m
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "RESTRequest.h"


@implementation RESTRequest

@synthesize URL=_URL;
@synthesize options=_options;

#pragma mark -
#pragma mark Initialization

+ (id)requestWithURL:(NSString *)URLString options:(NSDictionary *)options {
	return [[[RESTRequest alloc] initWithURL:URLString options:options] autorelease];
}

+ (id)requestWithURL:(NSString *)URLString {
	return [RESTRequest requestWithURL:URLString options:nil];
}

- (id)initWithURL:(NSString *)URLString options:(NSDictionary *)options {
	if (self = [self init]) {
		[self setURL:URLString];
		[self setOptions:options];
	}
	return self;
}

- (id)initWithURL:(NSString *)URLString {
	return [self initWithURL:URLString options:nil];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	TT_RELEASE_SAFELY(_URL);
	TT_RELEASE_SAFELY(_options);
	[super dealloc];
}

#pragma mark -
#pragma mark Public methods



@end
