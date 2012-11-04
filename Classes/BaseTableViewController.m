    //
//  BaseTableViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "BaseTableViewController.h"

static const NSTimeInterval kBannerSlideInAnimationDuration = 0.5;

@implementation BaseTableViewController

@synthesize query=_query;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTableViewStyle:UITableViewStyleGrouped];
		[self setStatusBarStyle:UIStatusBarStyleDefault];
		[self setVariableHeightRows:YES];
		_query = [query retain];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
	[[self navigationController] setToolbarHidden:YES animated:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self updateViewFramesWithOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self updateViewFramesWithOrientation:[self interfaceOrientation] duration:kBannerSlideInAnimationDuration];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)updateViewFramesWithOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{
	
	[UIView commitAnimations];
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

#pragma mark -
#pragma mark Request delegate

- (void)request:(TTURLRequest*)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge {
	if ([challenge previousFailureCount] > 5) 
		return [[challenge sender] cancelAuthenticationChallenge:challenge];
	
	NSURL * url = [NSURL URLWithString:[[self query] valueForKey:@"url"]];	
	NSURLProtectionSpace *protectionSpace = [NSURLProtectionSpace protectionSpaceWithURL:url];
	NSDictionary * credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
	if (credentials) {
		NSURLCredential * credential = (NSURLCredential*)[[credentials allValues] objectAtIndex:0];
		return [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	}
	
	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
