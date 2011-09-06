//
//  IssueTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "IssueTableController.h"

@implementation IssueTableController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"Issues", @"")];
		
		NSURL * url = [NSURL URLWithString:[query valueForKey:@"url"]];
		NSMutableString * URLString = [[[url absoluteString] stringByAppendingRelativeURL:@"issues.xml"] mutableCopy];

		NSString * params = [query valueForKey:@"params"];
		if (params)	[URLString appendFormat:@"?%@",params];
		
		// Legacy support
		NSString * xPath = [NSString stringWithFormat:@"//link[@type='application/atom+xml' and contains(@href, '%@')]",params];
		_atomFeed = [[[AtomFeed alloc] initWithURL:[url absoluteString] path:@"my/page" xPath:xPath] retain];
		[_atomFeed setDelegate:self];
		[_atomFeed setDidFinishSelector:@selector(fetchFinished:)];
		[_atomFeed setDidFailSelector:@selector(fetchFailed:)];

		_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
		[_request setCachePolicy:TTURLRequestCachePolicyNoCache];

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
#pragma mark Atom feed selectors

- (void)fetchFinished:(AtomFeed*)feed {	
	id response = [[feed response] valueForKey:@"entry"];	
	if (!response) {
		[self setEmptyView:[[TTErrorView alloc] initWithTitle:NSLocalizedString(@"No issues found", @"") 
													 subtitle:nil
														image:nil]];
		return [self setLoadingView:nil];
	}

	BOOL isArray = [response isKindOfClass:[NSArray class]];
	NSArray * issues = isArray? response : [NSArray arrayWithObject:response];
	
	NSArray * featureTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FeatureCellTypes"];
	NSString * featurePattern = [NSString stringWithFormat:@".*(%@).*",[featureTypes componentsJoinedByString:@"|"]];
	
	NSArray * revisionTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RevisionCellTypes"];
	NSString * revisionPattern = [NSString stringWithFormat:@".*(%@).*",[revisionTypes componentsJoinedByString:@"|"]];
	
	NSArray * errorTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ErrorCellTypes"];
	NSString * errorPattern = [NSString stringWithFormat:@".*(%@).*",[errorTypes componentsJoinedByString:@"|"]];
	
	TTListDataSource * ds = [TTListDataSource dataSourceWithItems:[NSMutableArray array]];
	
	for (NSDictionary * issue in issues) {
		NSDate * timestamp = [NSDate dateFromXMLString:[issue valueForKeyPath:@"updated.___Entity_Value___"]];
		NSString * author = [issue valueForKeyPath:@"author.name.___Entity_Value___"];
		NSString * subject = [issue valueForKeyPath:@"title.___Entity_Value___"];
		NSString * URLString = [issue valueForKeyPath:@"link.href"];
		NSString * description = [[issue valueForKeyPath:@"content.___Entity_Value___"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([[issue valueForKeyPath:@"content.type"] isEqualToString:@"html"])
			description = [description stringByRemovingHTMLTags];
		
		NSString * imageURL = @"bundle://support.png";
		if ([subject matchedByPattern:featurePattern options:REG_ICASE])
			imageURL = @"bundle://feature.png";
		else if ([subject matchedByPattern:revisionPattern options:REG_ICASE])
			imageURL = @"bundle://revision.png";
		else if ([subject matchedByPattern:errorPattern options:REG_ICASE])
			imageURL = @"bundle://error.png";
		
		[[ds items] addObject:[TTTableMessageItem itemWithTitle:subject caption:author text:description timestamp:timestamp imageURL:imageURL URL:URLString]];
	}
	
	NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
	[[ds items] sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[self setDataSource:ds];
}

- (void)fetchFailed:(AtomFeed*)feed {
	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:NSLocalizedString(@"Connection Error", @"") 
												 subtitle:[[feed error] localizedDescription]
													image:nil]];	
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
	if ([error code] == 404)
		return [_atomFeed fetch];

	[self setLoadingView:nil];
	[self setErrorView:[[TTErrorView alloc] initWithTitle:TTLocalizedString(@"Connection Error", @"") 
												 subtitle:[error localizedDescription]
													image:nil]];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {	
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	NSArray * issues = [dict valueForKey:@"___Array___" ];
	
	if (!issues || ![issues count]) {
		[self setEmptyView:[[TTErrorView alloc] initWithTitle:NSLocalizedString(@"No issues found", @"") 
													 subtitle:nil
														image:nil]];
		return [self setLoadingView:nil];
	}
	
	NSArray * featureTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FeatureCellTypes"];
	NSString * featurePattern = [NSString stringWithFormat:@".*(%@).*",[featureTypes componentsJoinedByString:@"|"]];
	
	NSArray * revisionTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RevisionCellTypes"];
	NSString * revisionPattern = [NSString stringWithFormat:@".*(%@).*",[revisionTypes componentsJoinedByString:@"|"]];
	
	NSArray * errorTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ErrorCellTypes"];
	NSString * errorPattern = [NSString stringWithFormat:@".*(%@).*",[errorTypes componentsJoinedByString:@"|"]];
	
	TTListDataSource * ds = [TTListDataSource dataSourceWithItems:[NSMutableArray array]];
	
	for (NSDictionary * issue in issues) {
		NSString * description = [issue valueForKeyPath:@"description.___Entity_Value___"];
		NSString * author = [issue valueForKeyPath:@"author.name"];
		NSString * subject = [issue valueForKeyPath:@"subject.___Entity_Value___"];
		NSString * identifier = [issue valueForKeyPath:@"id.___Entity_Value___"];
		NSString * tracker = [issue valueForKeyPath:@"tracker.name"];
		NSDate * timestamp = [NSDate dateFromXMLString:[issue valueForKeyPath:@"updated_on.___Entity_Value___"]];
		
		NSMutableDictionary * newQuery = [[self query] mutableCopy];
		[newQuery setObject:identifier forKey:@"issue"];		
		NSString * URLString = [@"iredmine://issue" stringByAddingQueryDictionary:newQuery];
		
		NSString * imageURL = @"bundle://support.png";
		if ([tracker matchedByPattern:featurePattern options:REG_ICASE])
			imageURL = @"bundle://feature.png";
		else if ([tracker matchedByPattern:revisionPattern options:REG_ICASE])
			imageURL = @"bundle://revision.png";
		else if ([tracker matchedByPattern:errorPattern options:REG_ICASE])
			imageURL = @"bundle://error.png";
		
		[[ds items] addObject:[TTTableMessageItem itemWithTitle:subject caption:author text:description timestamp:timestamp imageURL:imageURL URL:URLString]];
	}
	
	NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
	[[ds items] sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
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
