//
//  ProjectViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 14.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "ProjectViewController.h"

@implementation ProjectViewController

@synthesize connector=_connector;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
		[self setTitle:TTLocalizedString(@"Loading...", @"")];
		
		NSString * login = [query valueForKey:@"login"];
		NSString * password = [query valueForKey:@"password"];
		_connector = [[RMConnector connectorWithUrlString:[url absoluteString] username:login password:password] retain];
		[_connector setDidFinishSelector:@selector(didFinishConnect:)];
		[_connector setDidFailSelector:@selector(didFailConnect:)];
		[_connector setDelegate:self];
		[_connector start];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reloadData:self];
	[_connector start];
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
	[self reloadData:self];
}

#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)reloadData:(id)sender {
	if (![[_connector responseDictionary] count]) 
		return;
		
	NSString * projectURL = [[self query] valueForKey:@"project"];
	NSString * login	= [[self query] valueForKey:@"login"];
	NSString * password = [[self query] valueForKey:@"password"];	
	NSString * activitiesURL = [@"iredmine://activities" stringByAddingQueryDictionary:[self query]];
	NSString * issuesURL = [@"iredmine://issues" stringByAddingQueryDictionary:[self query]];

	NSString * addURL = [@"iredmine://issue/add" stringByAddingQueryDictionary:[self query]];
	NSArray * purchases = [[NSUserDefaults standardUserDefaults] valueForKey:@"purchases"];
	if (!purchases || ![purchases containsObject:kInAppPurchaseIdentifierPro])
		addURL = @"iredmine://store";
	
	NSDictionary * projectsDict = [[_connector responseDictionary] valueForKeyPath:@"projects.content"];
	NSDictionary * projectDict = [projectsDict valueForKey:projectURL];
	NSDictionary * activityDict = [projectDict valueForKey:@"activity"];
	NSDictionary * issuesDict = [projectDict valueForKey:@"issues"];

	NSString * issuesTitle = [NSLocalizedString(@"Issues",@"") stringByAppendingFormat:@" (%d)",[issuesDict count]];
	NSString * activityTitle = [NSLocalizedString(@"Activities",@"") stringByAppendingFormat:@" (%d)",[activityDict count]];
	
	NSArray * titleComps = [[projectDict valueForKey:@"title"] componentsSeparatedByString:@" - "];
	[self setTitle:[titleComps objectAtIndex:0]];	
	TTSectionedDataSource * ds =[TTSectionedDataSource dataSourceWithObjects:
						 [titleComps lastObject],
						 [TTTableLongTextItem itemWithText:[[projectDict valueForKey:@"content"] stringByRemovingHTMLTags]],
						 @"",
						 [TTTableTextItem itemWithText:issuesTitle  URL:issuesURL],
						 [TTTableTextItem itemWithText:activityTitle URL:activitiesURL],
						 @"",
						 [TTTableButton itemWithText:NSLocalizedString(@"Show in web view",@"") URL:[projectDict valueForKey:@"href"]],
						 nil];
		
	if (login && ![login isEmptyOrWhitespace] && password && ![password isEmptyOrWhitespace])
		[[[ds items] lastObject] addObject:[TTTableButton itemWithText:NSLocalizedString(@"New issue",@"") URL:addURL]];
	
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
