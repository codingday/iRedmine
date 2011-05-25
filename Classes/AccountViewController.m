//
//  AccountViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 21.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "AccountViewController.h"


@implementation AccountViewController

@synthesize request=_request;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
		[self setTitle:[url host]];

		NSString * URLString = [[url absoluteString] stringByAppendingURLPathComponent:@"projects.xml?limit=1000"];
		_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
		[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
		[_request setHttpMethod:@"GET"];
		[_request send];
	}
	return self;
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
	
	NSURL * url = [NSURL URLWithString:[[self query] valueForKey:@"url"]];
	NSURLProtectionSpace *protectionSpace = [NSURLProtectionSpace protectionSpaceWithURL:url];
	NSDictionary * credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
	if (credentials) {
		NSMutableArray * myPage = [NSMutableArray array];
		NSMutableDictionary * newQuery = [[self query] mutableCopy];
		
		[newQuery setObject:@"issues.xml?assigned_to=me" forKey:@"path"];
		NSString * assignedURL = [@"iredmine://issues" stringByAddingQueryDictionary:newQuery];
		[myPage addObject:[TTTableTextItem itemWithText:NSLocalizedString(@"Issues assigned to me",@"") URL:assignedURL]];
			
		[newQuery setObject:@"issues.xml?author=me" forKey:@"path"];
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
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
	[super dealloc];
}

@end

