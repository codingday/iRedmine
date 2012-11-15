//
//  ProjectAddViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "ProjectAddViewController.h"


@implementation ProjectAddViewController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"New project",@"")];
		[self setToolbarItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cam:)]]];
		[self setAutoresizesForKeyboard:YES];
		
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
		NSString * URLString = [[url absoluteString] stringByAppendingRelativeURL:@"projects.xml"];
		
		_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
		[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
		[_request setHttpMethod:@"POST"];

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
	
	_nameField = [[[UITextField alloc] init] retain];
	TTTableControlItem * nameItem = [TTTableControlItem itemWithCaption:NSLocalizedString(@"Name", @"") control:_nameField];

	_identifierField = [[[UITextField alloc] init] retain];
	[_identifierField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	TTTableControlItem * identifierItem = [TTTableControlItem itemWithCaption:NSLocalizedString(@"Identifier", @"") control:_identifierField];
	
	_homepageField = [[[UITextField alloc] init] retain];
	[_homepageField setKeyboardType:UIKeyboardTypeURL];
	[_homepageField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_homepageField setAutocorrectionType:UITextAutocorrectionTypeNo];
	TTTableControlItem * homepageItem = [TTTableControlItem itemWithCaption:NSLocalizedString(@"Homepage", @"") control:_homepageField];
	
	_isPublicSwitch = [[[UISwitch alloc] init] retain];
	[_isPublicSwitch setOn:YES];
	TTTableControlItem * isPublicItem = [TTTableControlItem itemWithCaption:NSLocalizedString(@"Public", @"") control:_isPublicSwitch];
	
	_descriptionEditor = [[[TTTextEditor alloc] init] retain];
	TTTableControlItem * descriptionItem = [TTTableControlItem itemWithCaption:nil control:(UIControl*)_descriptionEditor];
	
	[self setDataSource:[TTSectionedDataSource dataSourceWithObjects:@"",nameItem,identifierItem,homepageItem,isPublicItem,NSLocalizedString(@"Description", @""),descriptionItem,nil]];	
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[_login setDelegate:nil];
	[_login cancel];
	TT_RELEASE_SAFELY(_login);
	
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
	
	TT_RELEASE_SAFELY(_nameField);
	TT_RELEASE_SAFELY(_identifierField);
	TT_RELEASE_SAFELY(_homepageField);
	TT_RELEASE_SAFELY(_isPublicSwitch);
	TT_RELEASE_SAFELY(_descriptionEditor);
	[super dealloc];
}


#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)send:(id)sender {	
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setNonEmptyString:[_nameField text] forKey:@"name"];
	[dict setNonEmptyString:[_identifierField text] forKey:@"identifier"];
	[dict setNonEmptyString:[_homepageField text] forKey:@"homepage"];
	[dict setNonEmptyString:[_descriptionEditor text] forKey:@"description"];
	[dict setObject:[NSNumber numberWithBool:[_isPublicSwitch isOn]] forKey:@"is_public"];
	[_request setDictionary:[NSDictionary dictionaryWithObject:dict forKey:@"project"]];
	
	if (![_login start])
		[_request send];
}

- (IBAction)cancel:(id)sender {	
	[_login cancel];
	[_request cancel];
	[self dismissViewControllerAnimated:YES completion:nil];
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
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	NSString * identifier	= [dict valueForKeyPath:@"identifier.___Entity_Value___" ];
	NSString * name			= [dict valueForKeyPath:@"name.___Entity_Value___" ];
	if ([identifier isEqualToString:[_identifierField text]] && [name isEqualToString:[_nameField text]])
		return [self cancel:self];
	
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

	NSString * errorMessage = [error localizedDescription];
	if ([error code] == 422)
		errorMessage = NSLocalizedString(@"RMProjectCreationValidationFailures",@"");
		
	[[[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Error", @"") 
								 message:errorMessage
								delegate:nil 
					   cancelButtonTitle:TTLocalizedString(@"OK", @"") 
					   otherButtonTitles:nil] autorelease] show];
}

@end
