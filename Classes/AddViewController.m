//
//  AddViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "AddViewController.h"

static AddViewController *_sharedAddViewController = nil;

@implementation AddViewController

@synthesize loginField;
@synthesize passwordField;
@synthesize hostField;
@synthesize portField;
@synthesize sslSwitch;
@synthesize oldTintColor;

+ (AddViewController *)sharedAddViewController{
	if (!_sharedAddViewController) {
		_sharedAddViewController = [[self alloc] initWithNibName:@"AddView" bundle:nil];
	}
	return _sharedAddViewController;	
}
	 
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == hostField) {
		[textField resignFirstResponder];
		[loginField becomeFirstResponder];
	} else if (textField == loginField) {
	    [textField resignFirstResponder];
		[passwordField becomeFirstResponder];
	} else if (textField == passwordField) {
	    [textField resignFirstResponder];
		[self acceptAction:textField];
	}
	return YES;
}	 

- (void)textFieldDidBeginEditing:(UITextField *)textField{ 
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(acceptAction:)] autorelease];
}

- (IBAction)acceptAction:(id)sender{
	if([[hostField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0){
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error adding account",@"Error adding account") message:NSLocalizedString(@"Please enter a valid host",@"Please enter a valid host") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
		[hostField becomeFirstResponder];
		return;
	}

	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * accounts = [[defaults dictionaryForKey:@"accounts"] mutableCopy];
	NSMutableDictionary * newAccount = [NSMutableDictionary dictionary];
	[newAccount setValue:[hostField.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"hostname"];
	[newAccount setValue:[loginField.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"username"];
	[newAccount setValue:[passwordField.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"password"];
	[newAccount setValue:[NSNumber numberWithBool:sslSwitch.on] forKey:@"ssl"];
	[newAccount setValue:[NSNumber numberWithInt:[portField.text intValue]] forKey:@"port"];
	[accounts setValue:newAccount forKey:hostField.text];
	[defaults setObject:accounts forKey:@"accounts"];	
	[defaults synchronize];
	NSArray * viewControllers = [self.navigationController viewControllers];
	RootViewController * rootController = [viewControllers objectAtIndex:0];
	[rootController refreshProjects:self];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      
	[self setTitle:NSLocalizedString(@"New account",@"New account")];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:YES];
	self.navigationController.navigationBar.barStyle = oldBarStyle;	
	self.navigationController.navigationBar.tintColor = [oldTintColor autorelease];	
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	oldBarStyle = self.navigationController.navigationBar.barStyle;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	oldTintColor = [self.navigationController.navigationBar.tintColor retain];	
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];		
	[hostField becomeFirstResponder];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			return YES;
		default:
			return NO;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[loginField release];
	[passwordField release];
	[hostField release];
	[portField release];
	[sslSwitch release];
	[oldTintColor release];
    [super dealloc];
}


@end
