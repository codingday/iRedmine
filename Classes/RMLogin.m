//
//  RMLogin.m
//  iRedmine
//
//  Created by Thomas Stägemann on 02.06.10.
//  Copyright 2010 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "RMLogin.h"

@interface RMLogin (PrivateMethods)

- (void) didStart;
- (void) didFinish;
- (void) didFailWithError:(NSError*)anError;

@end

@implementation RMLogin

@synthesize backURL;
@synthesize delegate;
@synthesize didStartSelector;
@synthesize didFinishSelector;
@synthesize didFailSelector;
@synthesize error;

#pragma mark -
#pragma mark Connector Basics

- (void) dealloc {
	[backURL release];
	[fetchRequest release];
	[loginRequest release];
	[delegate release];
	[error release];
	
	[super dealloc];
}

+ (id) loginWithURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass {
	return [[[RMLogin alloc] initWithURL:url username:user password:pass] autorelease];
}

- (id) initWithURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass {
	self = [super init];
	
	if (self) {						
		[self setBackURL:[NSURL URLWithString:@"my/page" relativeToURL:url]];
		NSURL * loginURL = [NSURL URLWithString:@"login" relativeToURL:url];
		fetchRequest = [[ASIHTTPRequest requestWithURL:loginURL] retain];
		[fetchRequest setTimeOutSeconds:100];
		//[fetchRequest setUseKeychainPersistance:YES];
		[fetchRequest setShouldPresentAuthenticationDialog:YES];
		[fetchRequest setDelegate:self];
		[fetchRequest setDidFinishSelector:@selector(fetchCompleted:)];
		[fetchRequest setDidFailSelector:@selector(fetchFailed:)];
		[fetchRequest setDidStartSelector:@selector(fetchBegan:)];	
		[fetchRequest setValidatesSecureCertificate:![[url scheme] isEqualToString:@"https"]];		

		loginRequest = [[ASIFormDataRequest requestWithURL:loginURL] retain];
		[loginRequest setTimeOutSeconds:100];
		//[loginRequest setUseKeychainPersistance:YES];
		[loginRequest setShouldPresentAuthenticationDialog:YES];
		[loginRequest setDelegate:self];
		[loginRequest setDidFinishSelector:@selector(loginCompleted:)];
		[loginRequest setDidFailSelector:@selector(loginFailed:)];
		[loginRequest setDidStartSelector:@selector(loginBegan:)];	
		[loginRequest setPostValue:user forKey:@"username"];
		[loginRequest setPostValue:pass forKey:@"password"];
		[loginRequest setPostValue:@"1" forKey:@"autologin"];
		[loginRequest setValidatesSecureCertificate:[fetchRequest validatesSecureCertificate]];		
	}
	
	return self;
}

- (void) startAsynchronous {
	[fetchRequest startAsynchronous];
}

- (void) cancel {
	if ([fetchRequest isExecuting])	[fetchRequest cancel];
	else if ([loginRequest isExecuting]) [loginRequest cancel];
}

#pragma mark -
#pragma mark Response methods

- (NSString *)responseString {
	return [loginRequest responseString];
}

- (NSData *)responseData {
	return [loginRequest responseData];
}

- (NSArray *)responseCookies {
	return [loginRequest responseCookies];
}

#pragma mark -
#pragma mark Request methods

- (void) fetchBegan:(ASIHTTPRequest *)aRequest {
	NSLog(@"fetching login on: %@",[aRequest url]);
	[self didStart];
}

- (void) fetchFailed:(ASIHTTPRequest *)aRequest {
	NSLog(@"fetching login failed: %@",[[aRequest error] localizedDescription]);
	[self didFailWithError:[aRequest error]];
}

- (void) fetchCompleted:(ASIHTTPRequest *)aRequest {
	// Extract auth token from response html and login
	TFHpple * xpathParser = [[[TFHpple alloc] initWithHTMLData:[aRequest responseData]] autorelease];
	TFHppleElement * tokenElement = [xpathParser at:@"//input[@name='authenticity_token']"];
	NSString * token = [tokenElement objectForKey:@"value"];
	if (token) [loginRequest setPostValue:token forKey:@"authenticity_token"];
	[loginRequest setPostValue:[backURL absoluteString] forKey:@"back_url"];
	[loginRequest setRequestCookies:[[aRequest responseCookies] mutableCopy]];
	[loginRequest startAsynchronous];
}

- (void) loginBegan:(ASIFormDataRequest *)aRequest {
	NSLog(@"login on: %@",[aRequest url]);
}

- (void) loginFailed:(ASIFormDataRequest *)aRequest {
	NSLog(@"login failed: %@",[[aRequest error] localizedDescription]);
	[self didFailWithError:[aRequest error]];
}

- (void) loginCompleted:(ASIFormDataRequest *)aRequest {
	NSLog(@"logged on: %@; status code: %d",[aRequest url],[aRequest responseStatusCode]);
	[self didFinish];
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

- (void) didFailWithError:(NSError*)anError {
	error = [anError retain];
	
	// Let the delegate know something went wrong
	if ([self didFailSelector] && [[self delegate] respondsToSelector:[self didFailSelector]])
		[[self delegate] performSelectorOnMainThread:[self didFailSelector] withObject:self waitUntilDone:[NSThread isMainThread]];	
}

@end
