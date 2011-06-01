//
//  Login.m
//  iRedmine
//
//  Created by Thomas Stägemann on 02.06.10.
//  Copyright 2010 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "Login.h"

@interface Login (PrivateMethods)

- (void) didStart;
- (void) didFinish;
- (void) didFail;

@end

@implementation Login

@synthesize username=_username;
@synthesize password=_password;
@synthesize backURL=_backURL;
@synthesize delegate=_delegate;
@synthesize didStartSelector=_didStartSelector;
@synthesize didFinishSelector=_didFinishSelector;
@synthesize didFailSelector=_didFailSelector;
@synthesize error=_error;

#pragma mark -
#pragma mark Connector Basics

- (void)dealloc {
	TT_RELEASE_SAFELY(_username);
	TT_RELEASE_SAFELY(_password);
	TT_RELEASE_SAFELY(_backURL);
	TT_RELEASE_SAFELY(_fetchRequest);
	TT_RELEASE_SAFELY(_loginRequest);
	TT_RELEASE_SAFELY(_delegate);
	TT_RELEASE_SAFELY(_error);
	
	[super dealloc];
}

+ (id)loginWithURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass {
	return [[[Login alloc] initWithURL:url username:user password:pass] autorelease];
}

- (id)initWithURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass {
	self = [super init];
	
	if (self) {		
		[self setUsername:user];
		[self setPassword:pass];
		[self setBackURL:[NSURL URLWithString:@"my/page" relativeToURL:url]];
		NSURL * loginURL = [NSURL URLWithString:@"login" relativeToURL:url];
		
		_fetchRequest = [[TTURLRequest requestWithURL:[loginURL absoluteString] delegate:self] retain];
		[_fetchRequest setResponse:[[[TTURLDataResponse alloc] init] autorelease]];
		[_fetchRequest setCachePolicy:TTURLRequestCachePolicyNone];

		_loginRequest = [[TTURLRequest requestWithURL:[loginURL absoluteString] delegate:self] retain];
		[_loginRequest setResponse:[[[TTURLDataResponse alloc] init] autorelease]];
		[_loginRequest setCachePolicy:TTURLRequestCachePolicyNone];
		[_loginRequest setFilterPasswordLogging:YES];
		[_loginRequest setHttpMethod:@"POST"];
		[_loginRequest setValue:[loginURL absoluteString] forHTTPHeaderField:@"Referer"];
	}
	
	return self;
}

- (BOOL)start {
	if (!_username || !_password) 
		return NO;
	[_fetchRequest send];
	return YES;
}

- (void)cancel {
	[_fetchRequest cancel];
	[_loginRequest cancel];
}

#pragma mark -
#pragma mark Response methods

- (NSString *)responseString {
	return [[NSString alloc] initWithData:[self responseData] encoding:NSASCIIStringEncoding];
}

- (NSData *)responseData {
	return [(TTURLDataResponse *)[_loginRequest response] data];
}

#pragma mark -
#pragma mark Event Methods

- (void) didStart {
	// Let the delegate know we have started
	if ([self didStartSelector]  && [[self delegate] respondsToSelector:[self didStartSelector]])
		[[self delegate] performSelectorOnMainThread:[self didStartSelector] withObject:self waitUntilDone:[NSThread isMainThread]];		
}

- (void) didFinish {
	// Let the delegate know we are done
	if ([self didFinishSelector] && [[self delegate] respondsToSelector:[self didFinishSelector]])
		[[self delegate] performSelectorOnMainThread:[self didFinishSelector] withObject:self waitUntilDone:[NSThread isMainThread]];		
}

- (void) didFail {
	// Let the delegate know something went wrong
	if ([self didFailSelector] && [[self delegate] respondsToSelector:[self didFailSelector]])
		[[self delegate] performSelectorOnMainThread:[self didFailSelector] withObject:self waitUntilDone:[NSThread isMainThread]];	
}

#pragma mark -
#pragma mark Request delegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
	if ([request isEqual:_fetchRequest])
		return [self didStart];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	_error = [error retain];
	[self didFail];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {	
	if ([request isEqual:_loginRequest]) 
		return [self didFinish];
	
	// Should be the fetch request
	NSData * data = [(TTURLDataResponse *)[_fetchRequest response] data];
	
	// Extract auth token from response html and login
	TFHpple * xpathParser = [[[TFHpple alloc] initWithHTMLData:data] autorelease];
	TFHppleElement * tokenElement = [xpathParser at:@"//input[@name='authenticity_token']"];
	NSString * token = [tokenElement objectForKey:@"value"];
	if (token) 
		[[_loginRequest parameters] setValue:token forKey:@"authenticity_token"];
	[[_loginRequest parameters] setValue:[_backURL absoluteString] forKey:@"back_url"];
	[[_loginRequest parameters] setValue:_username forKey:@"username"];
	[[_loginRequest parameters] setValue:_password forKey:@"password"];
	[_loginRequest send];	
}


@end
