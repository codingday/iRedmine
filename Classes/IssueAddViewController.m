//
//  IssueAddViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "IssueAddViewController.h"


@implementation IssueAddViewController

@synthesize request=_request;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"New issue",@"")];
		[self setToolbarItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cam:)]]];
		[self setAutoresizesForKeyboard:YES];
		
		NSString * URLString = [[query valueForKey:@"url"] stringByAppendingURLPathComponent:@"issues.xml"];
		_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
		[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
		[_request setHttpMethod:@"POST"];
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
	
	_subjectField = [[[UITextField alloc] init] retain];
	TTTableControlItem * subjectItem = [TTTableControlItem itemWithCaption:NSLocalizedString(@"Subject", @"") control:_subjectField];

	_descriptionEditor = [[[TTTextEditor alloc] init] retain];
	TTTableControlItem * descriptionItem = [TTTableControlItem itemWithCaption:nil control:(UIControl*)_descriptionEditor];
	
	[self setDataSource:[TTSectionedDataSource dataSourceWithObjects:@"",subjectItem,NSLocalizedString(@"Description", @""),descriptionItem,nil]];	
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[super viewDidUnload];

	TT_RELEASE_SAFELY(_request);
	TT_RELEASE_SAFELY(_subjectField);
	TT_RELEASE_SAFELY(_descriptionEditor);
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_request);
	TT_RELEASE_SAFELY(_subjectField);
	TT_RELEASE_SAFELY(_descriptionEditor);
	[super dealloc];
}


#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)send:(id)sender {	
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
						   [_subjectField text],
						   @"subject",
						   [_descriptionEditor text],
						   @"description",
						   [[[self query] valueForKey:@"project"] lastPathComponent],
						   @"project_id",
						   nil];
	
	// Send request
	[_request setDictionary:[NSDictionary dictionaryWithObject:dict forKey:@"issue"]];
	[_request send];
}

- (IBAction)cancel:(id)sender {	
	[_request cancel];
	[self dismissModalViewControllerAnimated:YES];
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

- (void)requestDidUploadData:(TTURLRequest*)request{
	NSLog(@"did upload: %@",request);
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	NSString * description = [dict valueForKeyPath:@"description.___Entity_Value___" ];
	NSString * subject = [dict valueForKeyPath:@"subject.___Entity_Value___" ];
	if ([subject isEqualToString:[_subjectField text]] && [description isEqualToString:[_descriptionEditor text]])
		return [self cancel:self];
	
	[[[self navigationItem] rightBarButtonItem] setEnabled:YES];
	
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

- (void)requestDidCancelLoad:(TTURLRequest*)request {
	NSLog(@"did cancel load: %@",request);
}

@end
