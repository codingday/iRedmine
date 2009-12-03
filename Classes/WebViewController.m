//
//  WebViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 07.05.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

@synthesize homeItem;
@synthesize webView;
@synthesize safariItem;
@synthesize issue;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supporting all orientations
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSString * title = [[[issue valueForKey:@"title"] componentsSeparatedByString:@": "] objectAtIndex:0];
	[self setTitle:title];
	
	NSURL * url;
	if ([title hasPrefix:@"Revision"]) {
		url = [NSURL URLWithString:[issue valueForKey:@"id"]];
	} else {
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=pdf",[issue valueForKey:@"id"]]];
	}

	NSURLRequest * request = [NSURLRequest requestWithURL:url];
	if (![request isEqual:[webView request]]) {
		[webView loadRequest:request];	
	}
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
	if(item == homeItem) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	} else if(item == safariItem) {	
		NSURL * url = [NSURL URLWithString:[issue valueForKey:@"id"]];
		[[UIApplication sharedApplication] openURL:url];
	}
	[tabBar setSelectedItem:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
 	[webView release];
	[safariItem release];
	[homeItem release];
	[issue release];
	[super dealloc];
}


@end
