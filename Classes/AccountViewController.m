//
//  AddViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "AccountViewController.h"

@implementation AccountViewController

@synthesize loginField=_loginField;
@synthesize passwordField=_passwordField;
@synthesize urlField=_urlField;

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
	if (self = [super initWithNibName:@"AccountView" bundle:nibBundleOrNil]) {
		[self setStatusBarStyle:UIStatusBarStyleBlackOpaque];
		[self setNavigationBarTintColor:[UIColor blackColor]];
		[self setTitle:NSLocalizedString(@"New account",@"")];
	}
	return self;
}

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		_query = [query retain];
	}
	return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _urlField) {
		[textField resignFirstResponder];
		[_loginField becomeFirstResponder];
	} else if (textField == _loginField) {
	    [textField resignFirstResponder];
		[_passwordField becomeFirstResponder];
	} else if (textField == _passwordField) {
	    [textField resignFirstResponder];
		[self add:textField];
	}
	return YES;
}	 

- (IBAction)add:(id)sender {	
	NSURL * url = [NSURL URLWithString:[[_urlField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	if ([[_urlField text] isEmptyOrWhitespace] || !url) {
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error adding account",@"") message:NSLocalizedString(@"Please enter a valid host",@"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
		[_urlField becomeFirstResponder];
		return;
	}
	
	NSString * urlString = [url absoluteString];
	NSString * lastChar  = [urlString substringFromIndex:[urlString length]];
	if(![lastChar isEqualToString:@"/"])
		urlString = [urlString stringByAppendingString:@"/"];
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * accounts = [[defaults dictionaryForKey:@"accounts"] mutableCopy];
	NSMutableDictionary * newAccount = [NSMutableDictionary dictionary];
	[newAccount setValue:urlString forKey:@"url"];
	[newAccount setValue:[_loginField text] forKey:@"username"];
	[newAccount setValue:[_passwordField text] forKey:@"password"];
	[accounts setValue:newAccount forKey:urlString];
	[defaults setObject:accounts forKey:@"accounts"];	
	[defaults synchronize];
	RootViewController * rootController = (RootViewController*)[[AdNavigator navigator] viewControllerForURL:@"iredmine://accounts"];
	[rootController connectWithURLString:urlString username:[_loginField text] password:[_passwordField text]];
	[self cancel:sender];
}

- (IBAction)cancel:(id)sender {	
	if ([[[self navigationController] topViewController] isEqual:self])
		[self dismissModalViewControllerAnimated:YES];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

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
	
	[_urlField		setText:[_query objectForKey:@"url"]];
	[_loginField	setText:[_query objectForKey:@"login"]];
	[_passwordField setText:[_query objectForKey:@"password"]];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_urlField becomeFirstResponder];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	TT_RELEASE_SAFELY(_loginField);
	TT_RELEASE_SAFELY(_passwordField);
	TT_RELEASE_SAFELY(_urlField);
	TT_RELEASE_SAFELY(_query);
    [super dealloc];
}


@end
