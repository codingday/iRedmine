//
//  AccountAddViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "AccountAddViewController.h"

@implementation AccountAddViewController

@synthesize loginField=_loginField;
@synthesize passwordField=_passwordField;
@synthesize urlField=_urlField;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
	if (self = [super initWithNibName:@"AccountView" bundle:nibBundleOrNil]) {
		[self setTitle:NSLocalizedString(@"New account",@"")];
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
	
	UIBarButtonItem * doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
	[[self navigationItem] setRightBarButtonItem:doneButton];
	
	NSURL * url = [NSURL URLWithString:[[self query] objectForKey:@"url"] ];
	[_urlField setText:[url absoluteString]];

	NSURLProtectionSpace *protectionSpace = [[[NSURLProtectionSpace alloc] initWithHost:[url host] port:[[url port] integerValue] protocol:[url scheme] realm:nil authenticationMethod:nil] autorelease];
	NSDictionary * credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
	if (credentials) {
		NSURLCredential * credential = (NSURLCredential*)[[credentials allValues] objectAtIndex:0];
		[_loginField	setText:[credential user]];
		[_passwordField setText:[credential password]];	
	}		
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_urlField becomeFirstResponder];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[_loginField setDelegate:nil];
	[_passwordField setDelegate:nil];
	[_urlField setDelegate:nil];
	
	TT_RELEASE_SAFELY(_loginField);
	TT_RELEASE_SAFELY(_passwordField);
	TT_RELEASE_SAFELY(_urlField);
    [super dealloc];
}

#pragma mark -
#pragma mark Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _urlField) {
		[textField resignFirstResponder];
		[_loginField becomeFirstResponder];
	} else if (textField == _loginField) {
	    [textField resignFirstResponder];
		[_passwordField becomeFirstResponder];
	} else if (textField == _passwordField) {
	    [textField resignFirstResponder];
		[self done:textField];
	}
	return YES;
}	

#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)done:(id)sender {	
	NSURL * url = [NSURL URLWithString:[_urlField text]];
	if ([[_urlField text] isEmptyOrWhitespace] || !url) {
		[_urlField becomeFirstResponder];
		return [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input error",@"") 
											message:NSLocalizedString(@"Please enter a valid host",@"") 
										   delegate:nil 
								  cancelButtonTitle:TTLocalizedString(@"OK",@"") 
								  otherButtonTitles:nil] autorelease] show];
	}
	
	NSArray * accounts = [[NSUserDefaults standardUserDefaults] arrayForKey:@"accounts"];
	if ([accounts containsObject:[url absoluteString]]) {
		return [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Account already exists",@"") 
											message:NSLocalizedString(@"Do you really want to override this account with the specified URL?",@"") 
										   delegate:self 
								  cancelButtonTitle:TTLocalizedString(@"Cancel",@"") 
								  otherButtonTitles:TTLocalizedString(@"Yes",@""),nil] autorelease] show];		
	}
	
	[self performSelector:@selector(save:)];
}


- (IBAction)cancel:(id)sender {	
	if ([[[self navigationController] topViewController] isEqual:self])
		[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Selectors

- (void)save:(id)sender {
	NSURL * url = [NSURL URLWithString:[_urlField text]];
	if (!url) return;
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray * accounts = [[defaults arrayForKey:@"accounts"] mutableCopy];

	NSURLCredentialStorage * storage = [NSURLCredentialStorage sharedCredentialStorage];
	NSURL * originalURL = [NSURL URLWithString:[[self query] objectForKey:@"url"]];
	if (originalURL) {
		NSURLProtectionSpace *originalSpace = [[[NSURLProtectionSpace alloc] initWithHost:[originalURL host]
																					 port:[[originalURL port] integerValue]
																				 protocol:[originalURL scheme]
																					realm:nil
																	 authenticationMethod:nil] autorelease];
		NSDictionary * dict = [storage credentialsForProtectionSpace:originalSpace];
		for (NSURLCredential * oldCredential in [dict allValues])
			[storage removeCredential:oldCredential forProtectionSpace:originalSpace];
		[accounts removeObject:[originalURL absoluteString]];
	}

	NSURLCredential * credential = [NSURLCredential credentialWithUser:[_loginField text] password:[_passwordField text] persistence:NSURLCredentialPersistencePermanent];
	NSURLProtectionSpace *protectionSpace = [[[NSURLProtectionSpace alloc] initWithHost:[url host] port:[[url port] integerValue] protocol:[url scheme] realm:nil authenticationMethod:nil] autorelease];
	[storage setDefaultCredential:credential forProtectionSpace:protectionSpace];
	
	[accounts addObject:[url absoluteString]];
	[defaults setObject:accounts forKey:@"accounts"];
	[defaults synchronize];
	
	[self cancel:sender];
}

#pragma mark -
#pragma mark Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) 
		[self performSelector:@selector(save:)];
}

@end
