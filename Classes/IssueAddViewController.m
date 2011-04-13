//
//  IssueAddViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "IssueAddViewController.h"


@implementation IssueAddViewController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setVariableHeightRows:YES];
		[self setTableViewStyle:UITableViewStyleGrouped];
		[self setStatusBarStyle:UIStatusBarStyleDefault];
		[self setTitle:NSLocalizedString(@"New issue",@"")];
		[self setToolbarItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cam:)]]];
		
		TTTableControlItem * subjectItem = [TTTableControlItem itemWithCaption:NSLocalizedString(@"Subject", @"") control:[[UITextField alloc] init]];
		TTTableControlItem * descriptionItem = [TTTableControlItem itemWithCaption:nil control:[[TTTextEditor alloc] init]];
		[self setDataSource:[TTSectionedDataSource dataSourceWithObjects:@"",subjectItem,NSLocalizedString(@"Description", @""),descriptionItem,nil]];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[[self view] setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];      

	if ([[[self navigationController] topViewController] isEqual:self]) {
		UIBarButtonItem * cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
		[[self navigationItem] setLeftBarButtonItem:cancelButton];
	}
	
	UIBarButtonItem * doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(add:)] autorelease];
	[[self navigationItem] setRightBarButtonItem:doneButton];
}

#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)add:(id)sender {	
	NSString * URLString = [[[self query] valueForKey:@"url"] stringByAppendingPathComponent:@"issues.xml"];
	NSData * xmlData = [@"<?xml version=\"1.0\"?><issue><subject>Example</subject><project_id>1</project_id><priority_id>4</priority_id></issue>" dataUsingEncoding:NSUTF8StringEncoding];
	TTURLRequest * request = [TTURLRequest requestWithURL:URLString delegate:self];
	[request setShouldHandleCookies:YES];
	[request setHttpMethod:@"POST"];
	[request setHttpBody:xmlData];
	[request setContentType:@"text/xml"];
	[request send];
	
}

- (IBAction)cancel:(id)sender {	
	if ([[[self navigationController] topViewController] isEqual:self])
		[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Request delegate

- (void)requestDidStartLoad:(TTURLRequest*)request{
}

- (void)requestDidUploadData:(TTURLRequest*)request{
	NSLog(@"response: %@",[request response]);
	[self cancel:self];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	NSLog(@"response: %@",[request response]);
	[self cancel:self];
}

- (void)request:(TTURLRequest*)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge {
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	[self cancel:self];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
	[self cancel:self];
}

@end
