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
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	NSString * title = [[[issue valueForKey:@"title"] componentsSeparatedByString:@": "] objectAtIndex:0];
	[self setTitle:title];
	
	NSArray * revisionTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RevisionCellTypes"];
	NSString * revisionPattern = [NSString stringWithFormat:@".*(%@).*",[revisionTypes componentsJoinedByString:@"|"]];

	NSString * format = @"";
	NSString * MIMEType;
	if ([title matchedByPattern:revisionPattern options:REG_ICASE]) 
		MIMEType = @"text/html";
	else {
		MIMEType = @"application/pdf";
		format = @"?format=pdf";
	}

	NSURL * url = [NSURL URLWithString:[issue valueForKey:@"href"]];
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
	[request setTimeOutSeconds:300];
	[request setUseKeychainPersistance:YES];
	[request setShouldPresentAuthenticationDialog:YES];
	if ([[[request url] scheme] isEqualToString:@"https"]) 
		[request setValidatesSecureCertificate:NO];
	
	[request start];	
	NSError *error = [request error];
	
	if (error) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:[[request url] host] message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
	}
	else
		[webView loadData:[request responseData] MIMEType:MIMEType textEncodingName:@"utf-8" baseURL:[url baseURL]];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if(item == homeItem)
		[self.navigationController popToRootViewControllerAnimated:YES];
	else if(item == safariItem)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[issue valueForKey:@"href"]]];
	[tabBar setSelectedItem:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:[issue valueForKey:@"href"] message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)dealloc {
 	[webView release];
	[safariItem release];
	[homeItem release];
	[issue release];
	[super dealloc];
}


@end
