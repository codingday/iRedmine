//
//  AccountViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 21.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "AccountViewController.h"


@implementation AccountViewController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
		[self setTitle:[url host]];
				
		NSString * URLString = [[url absoluteString] stringByAppendingRelativeURL:@"projects.xml?limit=100"];		
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

#pragma mark - 
#pragma mark Login selectors

- (void)loginFinished:(Login*)login {
	[_request send];
}

- (void)loginFailed:(Login*)login {
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:NSLocalizedString(@"Login failed", @"") 
												 subtitle:[[login error] localizedDescription]
													image:nil]];	
}

#pragma mark -
#pragma mark Request delegate

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	if ([error code] == 404) 
		return NSLog(@"No REST API");
	
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:TTLocalizedString(@"Connection Error", @"") 
												 subtitle:[error localizedDescription]
													image:nil]];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {	
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	NSArray * projects = [dict valueForKey:@"___Array___" ];
	
	if (!projects || ![projects count]) {
		[self setEmptyView:[[TTErrorView alloc] initWithTitle:NSLocalizedString(@"No projects found", @"") 
															subtitle:nil
															   image:nil]];
		return [self setLoadingView:nil];
	}
	
	
	TTSectionedDataSource * ds = [[[TTSectionedDataSource alloc] init] autorelease];
	[ds setSections:[NSMutableArray array]];
	[ds setItems:[NSMutableArray array]];
	
	Account * account = [Account accountWithURL:[[self query] valueForKey:@"url"]];
	if ([account username] && [account password]) {
		NSMutableArray * myPage = [NSMutableArray array];
		NSMutableDictionary * newQuery = [[self query] mutableCopy];
		
		[newQuery setObject:@"assigned_to=me" forKey:@"params"];
		NSString * assignedURL = [@"iredmine://issues" stringByAddingQueryDictionary:newQuery];
		[myPage addObject:[TTTableTextItem itemWithText:NSLocalizedString(@"Issues assigned to me",@"") URL:assignedURL]];
			
		[newQuery setObject:@"author=me" forKey:@"params"];
		NSString * authorURL = [@"iredmine://issues" stringByAddingQueryDictionary:newQuery];
		[myPage addObject:[TTTableTextItem itemWithText:NSLocalizedString(@"Reported issues",@"") URL:authorURL]];

		[[ds sections] addObject:NSLocalizedString(@"My Page",@"")]; 
		[[ds items] addObject:myPage];
	}
	
	NSMutableArray * rows = [NSMutableArray array];	
	for (NSDictionary * project in projects) {
		NSString * text = [project valueForKeyPath:@"name.___Entity_Value___"];
		NSString * subtitle = [project valueForKeyPath:@"description.___Entity_Value___"];
		NSString * identifier = [project valueForKeyPath:@"identifier.___Entity_Value___"];
		
		NSMutableDictionary * newQuery = [[self query] mutableCopy];
		[newQuery setObject:identifier forKey:@"project"];
		
		NSString * URLString = [@"iredmine://project" stringByAddingQueryDictionary:newQuery];
		[rows addObject:[TTTableSubtitleItem itemWithText:text subtitle:subtitle?subtitle:@" " URL:URLString]];
	}
	
	NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:YES];
	[rows sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[[ds items] addObject:rows]; 
	[[ds sections] addObject:NSLocalizedString(@"Projects",@"")]; 
	
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

