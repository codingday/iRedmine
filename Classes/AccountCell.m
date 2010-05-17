//
//  AccountCell.m
//  iRedmine
//
//  Created by Thomas Stägemann on 12.05.10.
//  Copyright 2010 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "AccountCell.h"


@implementation AccountCell

//	[sslImage setHidden:![[url scheme] isEqualToString:@"https"]];
- (void)setURL:(NSURL*)url {
	_url = [url retain];
	[sslImage setHidden:![[url scheme] isEqualToString:@"https"]];
}

- (NSURL *) url{
	return _url;
}

- (void)dealloc {
	[_url release];
	[sslImage release];
    [super dealloc];
}

@end
