//
//  AtomFeed.m
//  iRedmine
//
//  Created by Thomas Stägemann on 01.06.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "AtomFeed.h"

@interface AtomFeed (PrivateMethods)

- (void) didStart;
- (void) didFinish;
- (void) didFail;

@end

@implementation AtomFeed

@synthesize URL=_URL;
@synthesize path=_path;
@synthesize xPath=_xPath;
@synthesize delegate=_delegate;
@synthesize didStartSelector=_didStartSelector;
@synthesize didFinishSelector=_didFinishSelector;
@synthesize didFailSelector=_didFailSelector;
@synthesize error=_error;

#pragma mark -
#pragma mark Initialization

- (id)initWithURL:(NSString*)baseURL path:(NSString*)relativePath xPath:(NSString*)xPath {
	if (self = [super init]) {
		[self setURL:baseURL];
		[self setPath:relativePath];
		[self setXPath:xPath];
	}
	return self;
}


#pragma mark -
#pragma mark Fetch

- (void)fetch {
	[_pageRequest cancel];
	TT_RELEASE_SAFELY(_pageRequest);
	
	_pageRequest = [[TTURLRequest requestWithURL:[_URL stringByAppendingRelativeURL:_path] delegate:self] retain];
	[_pageRequest setResponse:[[[TTURLDataResponse alloc] init] autorelease]];
	[_pageRequest send];
}

#pragma mark -
#pragma mark Response methods

- (NSDictionary *)response {
	return [(TTURLXMLResponse *)[_feedRequest response] rootObject];
}

#pragma mark -
#pragma mark Request delegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
	if ([request isEqual:_pageRequest])
		return [self didStart];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	_error = [error retain];
	[self didFail];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {	
	if ([request isEqual:_feedRequest]) 
		return [self didFinish];

	TFHpple * parser = [[[TFHpple alloc] initWithHTMLData:[(TTURLDataResponse*)[request response] data]] autorelease];
	NSString * feedURL = [[parser at:_xPath] objectForKey:@"href"];
	if (![feedURL hasPrefix:_URL])
		feedURL = [_URL stringByAppendingRelativeURL:feedURL];
	
	[_feedRequest cancel];
	TT_RELEASE_SAFELY(_feedRequest);

	TTURLXMLResponse * response = [[[TTURLXMLResponse alloc] init] autorelease];
	[response setIsRssFeed:YES];
	
	_feedRequest = [[TTURLRequest requestWithURL:feedURL delegate:self] retain];
	[_feedRequest setResponse:response];
	[_feedRequest send];	
}

#pragma mark -
#pragma mark Event Methods

- (void) didStart {
	// Let the delegate know we have started
	if (_didStartSelector  && [_delegate respondsToSelector:_didStartSelector])
		[_delegate performSelectorOnMainThread:_didStartSelector withObject:self waitUntilDone:[NSThread isMainThread]];		
}

- (void) didFinish {
	// Let the delegate know we are done
	if (_didFinishSelector && [_delegate respondsToSelector:_didFinishSelector])
		[_delegate performSelectorOnMainThread:_didFinishSelector withObject:self waitUntilDone:[NSThread isMainThread]];		
}

- (void) didFail {
	// Let the delegate know something went wrong
	if (_didFailSelector && [_delegate respondsToSelector:_didFailSelector])
		[_delegate performSelectorOnMainThread:_didFailSelector withObject:self waitUntilDone:[NSThread isMainThread]];	
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	TT_RELEASE_SAFELY(_URL);
	TT_RELEASE_SAFELY(_path);
	TT_RELEASE_SAFELY(_xPath);
	TT_RELEASE_SAFELY(_error);
	
	[_pageRequest cancel];
	TT_RELEASE_SAFELY(_pageRequest);

	[_feedRequest cancel];
	TT_RELEASE_SAFELY(_feedRequest);

	[super dealloc];
}

@end
