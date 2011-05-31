//
//  IssueTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "IssueTableController.h"

@implementation IssueTableController

@synthesize request=_request;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"Issues", @"")];
		
		NSMutableString * URLString = [[[query valueForKey:@"url"] stringByAppendingRelativeURL:@"issues.xml"] mutableCopy];

		NSString * params = [query valueForKey:@"params"];
		if (params)	[URLString appendFormat:@"?%@",params];
		
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
		NSString * URLString = [[[self query] valueForKey:@"url"] stringByAppendingRelativeURL:[NSString stringWithFormat:@"issues/%@",identifier]];
		
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
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
	[super dealloc];
}

@end
