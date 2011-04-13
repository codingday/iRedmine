//
//  ActivityTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "ActivityTableController.h"

@implementation ActivityTableController

@synthesize connector=_connector;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"Activities", @"")];
		
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
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

#pragma mark -
#pragma mark Connector

- (void)didFailConnect:(RMConnector*)connector {
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:TTLocalizedString(@"Connection Error", @"") 
												 subtitle:[[connector error] localizedDescription]
													image:nil]];
}

- (void)didFinishConnect:(RMConnector*)connector {
	NSString * projectURL = [[self query] valueForKey:@"project"];
	
	NSDictionary * projectsDict = [[connector responseDictionary] valueForKeyPath:@"projects.content"];
	NSDictionary * projectDict = [projectsDict valueForKey:projectURL];
	NSDictionary * activityDict = [projectDict valueForKey:@"activity"];
	[self performSelector:@selector(update:) withObject:activityDict];
}

#pragma mark -
#pragma mark Helpers

- (void)update:(NSDictionary*)dict {
	NSArray * featureTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FeatureCellTypes"];
	NSString * featurePattern = [NSString stringWithFormat:@".*(%@).*",[featureTypes componentsJoinedByString:@"|"]];
	
	NSArray * revisionTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RevisionCellTypes"];
	NSString * revisionPattern = [NSString stringWithFormat:@".*(%@).*",[revisionTypes componentsJoinedByString:@"|"]];
	
	NSArray * errorTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ErrorCellTypes"];
	NSString * errorPattern = [NSString stringWithFormat:@".*(%@).*",[errorTypes componentsJoinedByString:@"|"]];
	
	TTListDataSource * ds = [TTListDataSource dataSourceWithItems:[NSMutableArray array]];
	
	for (NSDictionary * activity in [dict allValues]) {
		NSArray * titleComponents = [[activity valueForKey:@"title"] componentsSeparatedByString:@": "];
		NSString * itemTitle = [titleComponents objectAtIndex:0];
		NSString * itemText	= [titleComponents lastObject];
		NSString * imageURL = @"bundle://support.png";
		if ([itemTitle matchedByPattern:featurePattern options:REG_ICASE])
			imageURL = @"bundle://feature.png";
		else if ([itemTitle matchedByPattern:revisionPattern options:REG_ICASE])
			imageURL = @"bundle://revision.png";
		else if ([itemTitle matchedByPattern:errorPattern options:REG_ICASE])
			imageURL = @"bundle://error.png";
		NSDate * timestamp = [NSDate dateFromRedmineString:[activity valueForKey:@"updated"]];
		[[ds items] addObject:[TTTableMessageItem itemWithTitle:itemTitle 
														caption:[activity valueForKey:@"author"] 
														   text:itemText
													  timestamp:timestamp
													   imageURL:imageURL 
															URL:[activity valueForKey:@"href"]]];
	}
	NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
	[[ds items] sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
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
