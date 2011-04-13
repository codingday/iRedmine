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
		[self setStatusBarStyle:UIStatusBarStyleBlackOpaque];
		[self setNavigationBarTintColor:[UIColor blackColor]];
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
	
	[_urlField		setText:[[self query] objectForKey:@"url"]];
	[_loginField	setText:[[self query] objectForKey:@"login"]];
	[_passwordField setText:[[self query] objectForKey:@"password"]];	
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
	
	NSDictionary * accounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"accounts"];
	if ([accounts objectForKey:[url absoluteString]]) {
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
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * accounts = [[defaults dictionaryForKey:@"accounts"] mutableCopy];

	NSString * originalURL = [[self query] objectForKey:@"url"];
	if (originalURL) [accounts removeObjectForKey:originalURL];
	
	NSMutableDictionary * newAccount = [NSMutableDictionary dictionary];
	[newAccount setValue:[url absoluteString] forKey:@"url"];
	[newAccount setValue:[_loginField text] forKey:@"username"];
	[newAccount setValue:[_passwordField text] forKey:@"password"];
	[accounts setValue:newAccount forKey:[url absoluteString]];
	
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
