    //
//  IssueNotesViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 06.09.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "IssueNotesViewController.h"


@implementation IssueNotesViewController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"New notes",@"")];
		[self setToolbarItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cam:)]]];
		[self setAutoresizesForKeyboard:YES];
		
		NSString * identifier = [query valueForKey:@"issue"];
		NSString * path		  = [NSString stringWithFormat:@"issues/%@.xml",identifier];
		NSURL * url			  = [NSURL URLWithString:[query valueForKey:@"url"]];
		NSString * URLString  = [[url absoluteString] stringByAppendingRelativeURL:path];

		_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
		[_request setResponse:[[[TTURLDataResponse alloc] init] autorelease]];
		[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
		[_request setHttpMethod:@"PUT"];
		
		Account * account = [Account accountWithURL:[url absoluteString]];
		_login = [[Login loginWithURL:url username:[account username] password:[account password]] retain];
		[_login setDelegate:self];
		[_login setDidFinishSelector:@selector(loginFinished:)];
		[_login setDidFailSelector:@selector(loginFailed:)];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([[[self navigationController] topViewController] isEqual:self]) {
		UIBarButtonItem * cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
		[[self navigationItem] setLeftBarButtonItem:cancelButton];
	}
	
	UIBarButtonItem * sendButton = [[[UIBarButtonItem alloc] initWithTitle:TTLocalizedString(@"Send", @"") style:UIBarButtonItemStyleDone target:self action:@selector(send:)] autorelease];
	[[self navigationItem] setRightBarButtonItem:sendButton];
	
	_notesEditor = [[[TTTextEditor alloc] init] retain];
	TTTableControlItem * notesItem = [TTTableControlItem itemWithCaption:nil control:(UIControl*)_notesEditor];
	
	[self setDataSource:[TTSectionedDataSource dataSourceWithObjects:NSLocalizedString(@"Notes", @""),notesItem,nil]];	
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[_login setDelegate:nil];
	[_login cancel];
	TT_RELEASE_SAFELY(_login);
	
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
	
	TT_RELEASE_SAFELY(_notesEditor);
	[super dealloc];
}


#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)send:(id)sender {	
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setNonEmptyString:[_notesEditor text] forKey:@"notes"];
	[_request setDictionary:[NSDictionary dictionaryWithObject:dict forKey:@"issue"]];
	
	if (![_login start])
		[_request send];
}

- (IBAction)cancel:(id)sender {	
	[_login cancel];
	[_request cancel];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - 
#pragma mark Login selectors

- (void)loginFinished:(Login*)login {
	[_request send];
}

- (void)loginFailed:(Login*)login {
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:NSLocalizedString(@"Authentication failed", @"") 
												 subtitle:[[login error] localizedDescription]
													image:nil]];	
}

#pragma mark -
#pragma mark Request delegate

- (void)requestDidStartLoad:(TTURLRequest*)request{
	[[[self navigationItem] rightBarButtonItem] setEnabled:NO];
	
	TTActivityLabel * activityLabel = [[[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleBlackBox] autorelease];
	[activityLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[activityLabel setText:TTLocalizedString(@"Sending...", @"")];
	[self setLoadingView:activityLabel];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	NSData * data = [(TTURLDataResponse *)[request response] data];
	if (data) return [self cancel:self];
	
	[[[self navigationItem] rightBarButtonItem] setEnabled:YES];
	[self setLoadingView:nil];
	
	[[[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Error", @"") 
								 message:TTLocalizedString(@"Sorry, there was an error.", @"") 
								delegate:nil 
					   cancelButtonTitle:TTLocalizedString(@"OK", @"") 
					   otherButtonTitles:nil] autorelease] show];		
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	[[[self navigationItem] rightBarButtonItem] setEnabled:YES];
	
	[self setLoadingView:nil];
	[[[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Error", @"") 
								 message:[error localizedDescription] 
								delegate:nil 
					   cancelButtonTitle:TTLocalizedString(@"OK", @"") 
					   otherButtonTitles:nil] autorelease] show];
}

@end
