    //
//  IssueViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 06.09.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "IssueViewController.h"


@implementation IssueViewController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {		
		[self setTitle:NSLocalizedString(@"Issue",@"")];	
		
		NSString * identifier = [query valueForKey:@"issue"];
		NSString * path		  = [NSString stringWithFormat:@"issues/%@.xml",identifier];
		NSURL * url			  = [NSURL URLWithString:[query valueForKey:@"url"]];
		NSString * URLString  = [[url absoluteString] stringByAppendingRelativeURL:path];
				
		_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
		[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
		[_request setHttpMethod:@"GET"];
		
		Account * account = [Account accountWithURL:[url absoluteString]];
		_login = [[Login loginWithURL:url username:[account username] password:[account password]] retain];
		[_login setDelegate:self];
		[_login setDidFinishSelector:@selector(loginFinished:)];
		[_login setDidFailSelector:@selector(loginFailed:)];
		
		if (![_login start])
			[_request send];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (![_login start])
		[_request send];
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

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:TTLocalizedString(@"Connection Error", @"") 
												 subtitle:[error localizedDescription]
													image:nil]];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {	
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	if (!dict) return;
	
	NSString * estimated   = [NSString stringWithFormat:NSLocalizedString(@"%0.0f hours",@""),[[dict valueForKeyPath:@"estimated_hours.___Entity_Value___"] doubleValue]];
	NSString * spent	   = [NSString stringWithFormat:NSLocalizedString(@"%0.0f hours",@""),[[dict valueForKeyPath:@"spent_hours.___Entity_Value___"] doubleValue]];
	NSString * description = [dict valueForKeyPath:@"description.___Entity_Value___"];
	NSString * identifier  = [dict valueForKeyPath:@"id.___Entity_Value___"];
	NSString * subject	   = [dict valueForKeyPath:@"subject.___Entity_Value___"];
	NSString * tracker	   = [dict valueForKeyPath:@"tracker.name"];
	NSString * status	   = [dict valueForKeyPath:@"status.name"];
	NSString * priority	   = [dict valueForKeyPath:@"priority.name"];
	NSString * author	   = [dict valueForKeyPath:@"author.name"];
	NSString * assignedTo  = [dict valueForKeyPath:@"assigned_to.name"];
	NSString * projectId   = [dict valueForKeyPath:@"project.id"];
	NSString * projectName = [dict valueForKeyPath:@"project.name"];
	NSString * startDate   = [[NSDate dateFromString:[dict valueForKeyPath:@"start_date.___Entity_Value___"] withFormat:@"yyyy-MM-dd"] formatDate];
	NSString * dueDate	   = [[NSDate dateFromString:[dict valueForKeyPath:@"due_date.___Entity_Value___"] withFormat:@"yyyy-MM-dd"] formatDate];
	NSString * created	   = [[NSDate dateFromXMLString:[dict valueForKeyPath:@"created_on.___Entity_Value___"]] formatRelativeTime];
	NSString * updated	   = [[NSDate dateFromXMLString:[dict valueForKeyPath:@"updated_on.___Entity_Value___"]] formatRelativeTime];
	
	[self setTitle:subject];	
	NSString * issueURL = [[[self query] valueForKey:@"url"] stringByAppendingRelativeURL:[NSString stringWithFormat:@"issues/%@",identifier]];
	
	UIProgressView * progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	[progressBar setProgress:([[dict valueForKeyPath:@"done_ratio.___Entity_Value___"] floatValue]/100.0)];
	
	NSMutableDictionary * newQuery = [[self query] mutableCopy];
	[newQuery setObject:projectId forKey:@"project"];
	NSString * projectURL = [@"iredmine://project" stringByAddingQueryDictionary:newQuery];
	
	TTSectionedDataSource * ds =[TTSectionedDataSource dataSourceWithObjects:
								 subject,
								 @"",
								 [TTTableButton itemWithText:NSLocalizedString(@"Show in web view",@"") URL:issueURL],
								 @"",
								 [TTTableCaptionItem itemWithText:projectName caption:NSLocalizedString(@"Project",@"") URL:projectURL],
								 [TTTableCaptionItem itemWithText:tracker caption:NSLocalizedString(@"Tracker",@"")],
								 [TTTableCaptionItem itemWithText:status caption:NSLocalizedString(@"Status",@"")],
								 [TTTableCaptionItem itemWithText:priority caption:NSLocalizedString(@"Priority",@"")],
								 [TTTableCaptionItem itemWithText:assignedTo caption:NSLocalizedString(@"Assignee",@"")],
								 @"",
								 [TTTableCaptionItem itemWithText:startDate caption:NSLocalizedString(@"Start date",@"")],
								 [TTTableCaptionItem itemWithText:dueDate caption:NSLocalizedString(@"Due date",@"")],
								 [TTTableCaptionItem itemWithText:spent caption:NSLocalizedString(@"Spent",@"")],
								 [TTTableCaptionItem itemWithText:estimated caption:NSLocalizedString(@"Estimated",@"")],
								 [TTTableControlItem itemWithCaption:NSLocalizedString(@"Done",@"") control:progressBar],
								 @"",
								 [TTTableCaptionItem itemWithText:created caption:NSLocalizedString(@"Created",@"")],
								 [TTTableCaptionItem itemWithText:author caption:NSLocalizedString(@"Author",@"")],
								 @"",
								 [TTTableGrayTextItem itemWithText:[NSString stringWithFormat:TTLocalizedString(@"Last updated: %@", @""),updated]],
								 nil];
	
	if (description && ![description isEmptyOrWhitespace])		
		[[[ds items] objectAtIndex:0] insertObject:[TTTableLongTextItem itemWithText:description] atIndex:0];
	
	Account * account = [Account accountWithURL:[[self query] valueForKey:@"url"]];
	if ([account username] && [account password]) {
		NSString * addURL = @"iredmine://store";
		NSArray * purchases = [[NSUserDefaults standardUserDefaults] valueForKey:@"purchases"];
		if (purchases && [purchases containsObject:kInAppPurchaseIdentifierPro])
			addURL = [@"iredmine://issue/comment" stringByAddingQueryDictionary:[self query]];
		[[[ds items] objectAtIndex:1] addObject:[TTTableButton itemWithText:NSLocalizedString(@"New notes",@"") URL:addURL]];
	}
	
	[self setDataSource:ds];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[_login setDelegate:nil];
	[_login cancel];
	TT_RELEASE_SAFELY(_login);
	
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
	
	[super dealloc];
}

@end
