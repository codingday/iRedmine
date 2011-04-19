//
//  AccountViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 21.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "AccountViewController.h"


@implementation AccountViewController

@synthesize connector=_connector;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
		[self setTitle:[url host]];

		NSString * login = [query valueForKey:@"login"];
		NSString * password = [query valueForKey:@"password"];
		NSString * URLString = ([[url absoluteString] hasSuffix:@"/"])? [url absoluteString] : [[url absoluteString] stringByAppendingString:@"/"];
		_connector = [[RMConnector connectorWithUrlString:URLString username:login password:password] retain];
		[_connector setDidFinishSelector:@selector(didFinishConnect:)];
		[_connector setDidFailSelector:@selector(didFailConnect:)];
		[_connector setDelegate:self];
		[_connector start];
	}
	return self;
}

#pragma mark -
#pragma mark Connector

- (void)didFailConnect:(RMConnector*)connector {
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:TTLocalizedString(@"Connection Error", @"") 
												 subtitle:[[connector error] localizedDescription]
													image:nil]];
}

- (void)didFinishConnect:(RMConnector*)connector {	
	TTSectionedDataSource * ds = [[[TTSectionedDataSource alloc] init] autorelease];
	[ds setSections:[NSMutableArray array]];
	[ds setItems:[NSMutableArray array]];
	
	NSString * login = [[self query] valueForKey:@"login"];
	NSString * password = [[self query] valueForKey:@"password"];
	NSDictionary * myPageDict = [[connector responseDictionary] valueForKey:@"myPage"];
	if (login && ![login isEmptyOrWhitespace] && password && ![password isEmptyOrWhitespace] && myPageDict && [myPageDict count]) {
		NSMutableArray * myPage = [NSMutableArray array];
		for (NSDictionary * issuesDict in [myPageDict allValues]) {
			NSMutableDictionary * newQuery = [[self query] mutableCopy];
			[newQuery setObject:[issuesDict valueForKey:@"href"] forKey:@"mypage"];
			NSString * issuesURL = [@"iredmine://mypage" stringByAddingQueryDictionary:newQuery];
			NSDictionary * issues = [issuesDict valueForKey:@"issues"];
			NSString * itemText = [NSLocalizedString([issuesDict valueForKey:@"title"],@"") stringByAppendingFormat:@" (%d)",[issues count]];
			[myPage addObject:[TTTableTextItem itemWithText:itemText URL:issuesURL]];
		}		
		[[ds sections] addObject:NSLocalizedString(@"My Page",@"")]; 
		[[ds items] addObject:myPage];
	}
	
	
	NSDictionary * projectsDict = [[connector responseDictionary] valueForKeyPath:@"projects.content"];
	
	if (projectsDict && [projectsDict count]) {
		NSMutableArray * projects = [NSMutableArray array];
		
		for (NSDictionary * projectDict in [projectsDict allValues]) {
			NSString * text = [[[projectDict valueForKey:@"title"] componentsSeparatedByString:@" - "] objectAtIndex:0];
			NSString * subtitle = [[projectDict valueForKey:@"content"] stringByRemovingHTMLTags];

			NSDictionary * projectQuery = [[self query] mutableCopy];
			[projectQuery setValue:[projectDict valueForKey:@"href"] forKey:@"project"];
		
			NSString * URLString = [@"iredmine://project" stringByAddingQueryDictionary:projectQuery];
			[projects addObject:[TTTableSubtitleItem itemWithText:text subtitle:subtitle?subtitle:@" " URL:URLString]];
		}
		NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:YES];
		[projects sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[[ds items] addObject:projects]; 
		[[ds sections] addObject:NSLocalizedString(@"Projects",@"")]; 
	}
	
	[self setDataSource:ds];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[_connector cancel];
	[_connector setDelegate:nil];
	TT_RELEASE_SAFELY(_connector);
	[super dealloc];
}

@end

