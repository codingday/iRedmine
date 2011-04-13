    //
//  BaseViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "BaseViewController.h"


@implementation BaseViewController

@synthesize query=_query;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		_query = [query retain];
	}
	return self;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
	[[self navigationController] setToolbarHidden:YES animated:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
	TT_RELEASE_SAFELY(_query);
}


- (void)dealloc {
	TT_RELEASE_SAFELY(_query);
    [super dealloc];
}

@end
