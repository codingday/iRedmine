//
//  ProjectViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 14.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "ProjectViewController.h"

@implementation ProjectViewController

@synthesize request=_request;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
		
		NSString * identifier = [query valueForKey:@"project"];
		NSString * path		  = [NSString stringWithFormat:@"projects/%@.xml",identifier];
		NSString * URLString  = [[[url absoluteString] stringByAppendingURLPathComponent:path] stringByAppendingString:@"?limit=100"];

		_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
		[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
		[_request setHttpMethod:@"GET"];
		[_request send];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reloadData:self];
	[_request send];
}

#pragma mark -
#pragma mark Request delegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
	[self setTitle:TTLocalizedString(@"Loading...", @"")];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:TTLocalizedString(@"Connection Error", @"") 
												 subtitle:[error localizedDescription]
													image:nil]];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {	
	[self reloadData:self];
}

#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)reloadData:(id)sender {
	NSDictionary * dict = [(TTURLXMLResponse *)[_request response] rootObject];
	if (!dict) return;
	
	NSString * description = [dict valueForKeyPath:@"description.___Entity_Value___"];
	NSString * identifier  = [dict valueForKeyPath:@"identifier.___Entity_Value___"];
	NSString * projectName = [dict valueForKeyPath:@"name.___Entity_Value___"];
	NSString * updated	   = [[NSDate dateFromXMLString:[dict valueForKeyPath:@"updated_on.___Entity_Value___"]] formatRelativeTime];
	
	[self setTitle:projectName];	
	NSURL * url = [NSURL URLWithString:[[self query] valueForKey:@"url"]];
	
	NSMutableDictionary * newQuery = [[self query] mutableCopy];
	[newQuery setObject:[NSString stringWithFormat:@"project_id=%@",identifier] forKey:@"params"];
	NSString * issuesURL = [@"iredmine://issues" stringByAddingQueryDictionary:newQuery];
	NSString * projectURL = [[url absoluteString] stringByAppendingURLPathComponent:[NSString stringWithFormat:@"projects/%@",identifier]];

	TTSectionedDataSource * ds =[TTSectionedDataSource dataSourceWithObjects:
								 projectName,
								 [TTTableTextItem itemWithText:NSLocalizedString(@"Issues",@"")  URL:issuesURL],
								 @"",
								 [TTTableButton itemWithText:NSLocalizedString(@"Show in web view",@"") URL:projectURL],
								 @"",
								 [TTTableGrayTextItem itemWithText:[NSString stringWithFormat:TTLocalizedString(@"Last updated: %@", @""),updated]],
								 nil];

	if (description && ![description isEmptyOrWhitespace])		
		[[[ds items] objectAtIndex:0] insertObject:[TTTableLongTextItem itemWithText:description] atIndex:0];
	
	Account * account = [Account accountWithURL:[url absoluteString]];
	if ([account username] && [account password]) {
		NSString * addURL = @"iredmine://store";
		NSArray * purchases = [[NSUserDefaults standardUserDefaults] valueForKey:@"purchases"];
		if (purchases && [purchases containsObject:kInAppPurchaseIdentifierPro])
			addURL = [@"iredmine://issue/add" stringByAddingQueryDictionary:[self query]];
		[[[ds items] objectAtIndex:1] addObject:[TTTableButton itemWithText:NSLocalizedString(@"New issue",@"") URL:addURL]];
	}
		
	[self setDataSource:ds];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
	[super dealloc];
}

@end
