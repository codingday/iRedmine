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

#pragma mark -
#pragma mark View lifecycle

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSString * title = [[[issue valueForKey:@"title"] componentsSeparatedByString:@": "] objectAtIndex:0];
	[self setTitle:title];
	
	NSString * href = [issue valueForKey:@"href"];
	if (href == nil) return;
	NSURL * url = [NSURL URLWithString:href];
	if (url == nil) return;

	// Get host, login and username, login and fetch page
	NSArray * accounts = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"accounts"] allValues];
	for (NSDictionary * account in accounts) {
		if ([href hasPrefix:[account valueForKey:@"url"]]) {
			NSString * username = [account valueForKey:@"username"];
			NSString * password = [account valueForKey:@"password"];
			
			id request;
			if ([password length] > 0 && [username length] > 0) {
				NSURL * hostURL = [NSURL URLWithString:[account valueForKey:@"url"]];
				request = [[RMLogin loginWithURL:hostURL username:username password:password] retain];
				[request setBackURL:url];
			}
			else {
				request = [[ASIHTTPRequest requestWithURL:url] retain];
				[request setTimeOutSeconds:100];
				//[request setUseKeychainPersistance:YES];
				[request setShouldPresentAuthenticationDialog:YES];
				[request setValidatesSecureCertificate:![[url scheme] isEqualToString:@"https"]];		
			}
			[request setDelegate:self];
			[request setDidFailSelector:@selector(requestDidFail:)];
			[request setDidFinishSelector:@selector(requestDidFinish:)];
			[request setDidStartSelector:@selector(requestDidStart:)];
			[request startAsynchronous];
			break;
		}
	}
	
}

#pragma mark -
#pragma mark Request methods

- (void)requestDidStart:(id)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)requestDidFail:(id)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:[issue valueForKey:@"href"] message:[[aRequest error] localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];	
}

- (void)requestDidFinish:(id)aRequest {
	NSURL * url = [NSURL URLWithString:[issue valueForKey:@"href"]];
	[webView loadHTMLString:[aRequest responseString] baseURL:url];		
}

#pragma mark -
#pragma mark Tab bar methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if(item == homeItem)
		[self.navigationController popToRootViewControllerAnimated:YES];
	else if(item == safariItem)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[issue valueForKey:@"href"]]];
	[tabBar setSelectedItem:nil];
}

#pragma mark -
#pragma mark Web view methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	return !(navigationType == UIWebViewNavigationTypeLinkClicked);
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

#pragma mark -
#pragma mark Memory management

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
