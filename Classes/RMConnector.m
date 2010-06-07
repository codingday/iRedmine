//
//  RMConnector.m
//  Hpple
//
//  Created by Frank Wittig on 06.05.10.
//  Copyright 2010 Frank Wittig <frank@lintuxhome.de>. All rights reserved.
//

#import "RMConnector.h"

@interface RMConnector (PrivateMethods)

- (void) didStart;
- (void) didFinish;
- (void) didFailWithError:(NSError*)anError;

- (void) login;
- (void) fetchMyPageFeedsWithCookies:(NSArray *)cookies;

- (void) fetchProjectsPageWithCookies:(NSArray *)cookies;
- (void) fetchProjectsFeedWithCookies:(NSArray *)cookies;

@end

@implementation RMConnector

@synthesize urlString;
@synthesize password;
@synthesize username;
@synthesize responseDictionary;
@synthesize delegate;
@synthesize didStartSelector;
@synthesize didFinishSelector;
@synthesize didFailSelector;
@synthesize error;

#pragma mark -
#pragma mark Connector Basics

- (void) dealloc {
	[urlString release];
	[username release];
	[password release];
	
	[responseDictionary release];
	[delegate release];
	[error release];
	
	[super dealloc];
}

+ (id) connectorWithUrlString:(NSString *) url username:(NSString *) user password:(NSString *) pass {
	return [[[RMConnector alloc] initWithUrlString:url username:user password:pass] autorelease];
}

+ (id) connectorWithUrlString:(NSString *) urlString {
	return [RMConnector connectorWithUrlString:urlString username:nil password:nil];
}

- (id) initWithUrlString:(NSString *) url username:(NSString *) user password:(NSString *) pass {
	self = [super init];
	
	if (self) {
		[self setUrlString:url];
		[self setUsername:user];
		[self setPassword:pass];
		
		responseDictionary = [[NSMutableDictionary dictionary] retain];
		NSDictionary * accounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"accounts"];	
		NSDictionary * account  = [accounts valueForKey:[self urlString]];
		if (account != nil)
			[responseDictionary setDictionary:[account valueForKey:@"data"]];
	}
	
	return self;
}

- (void) start {
	[self didStart];
	
	if ([[self username] length] > 0 && [[self password] length] > 0)
		[self login];
	else
		[self fetchProjectsPageWithCookies:nil];
}

- (void) cancel {
	// TODO: cancel current requests and fail with ASIRequestCancelledErrorType
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

#pragma mark -
#pragma mark Helper Methods

- (ASIHTTPRequest *)requestWithURL:(NSURL *)url cookies:(NSArray *)cookies startSelector:(SEL)startSelector finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector {
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url]; 
	[request setTimeOutSeconds:100];
	[request setRequestCookies:[cookies mutableCopy]];
	//[request setUseKeychainPersistance:YES];
	[request setShouldPresentAuthenticationDialog:YES];
	[request setDelegate:self];
	[request setDidFinishSelector:finishSelector];
	[request setDidFailSelector:failSelector];
	[request setDidStartSelector:startSelector];	
	[request setValidatesSecureCertificate:![[url scheme] isEqualToString:@"https"]];
	return request;
}

- (NSDictionary *)issuesWithURL:(NSURL *)feedURL cookies:(NSArray **)cookies error:(NSError **)err {
	ASIHTTPRequest * feedRequest = [self requestWithURL:feedURL cookies:*cookies startSelector:nil finishSelector:nil failSelector:nil];
	[feedRequest startSynchronous];
	*cookies = [feedRequest responseCookies];
	*err = [feedRequest error];
	if (*err) return nil;
	
	TFHpple * issuesParser = [[[TFHpple alloc] initWithHTMLData:[feedRequest responseData]] autorelease];
	NSArray *issuesArray = [issuesParser search:@"//feed/entry"];
	
	NSMutableDictionary * issuesDict = [NSMutableDictionary dictionary];
	for (int i = 1; i <= [issuesArray count]; i++) 
	{
		NSString * href = [[issuesParser at:[NSString stringWithFormat:@"//feed/entry[%d]/link", i]] objectForKey:@"href"];
		/* Sync to slow
		NSURL * issueURL = [NSURL URLWithString:href relativeToURL:[NSURL URLWithString:[self urlString]]];
		ASIHTTPRequest * issueRequest = [self requestWithURL:issueURL cookies:*cookies startSelector:nil finishSelector:nil failSelector:nil];
		[issueRequest startSynchronous];
		*cookies = [issueRequest responseCookies];
		*err = [issueRequest error];
		if (*err) return nil;
		*/
		
		// creating data structure to response	
		NSMutableDictionary * issueDict = [NSMutableDictionary dictionary];
		[issueDict setValue:href forKey:@"href"];
		[issueDict setValue:[[issuesParser at:[NSString stringWithFormat:@"//feed/entry[%d]/title", i]] content]		forKey:@"title"];
		[issueDict setValue:[[issuesParser at:[NSString stringWithFormat:@"//feed/entry[%d]/updated", i]] content]		forKey:@"updated"];
		[issueDict setValue:[[issuesParser at:[NSString stringWithFormat:@"//feed/entry[%d]/author/name", i]] content]	forKey:@"author"];
		[issueDict setValue:[[issuesParser at:[NSString stringWithFormat:@"//feed/entry[%d]/author/email", i]] content]	forKey:@"email"];
		//[issueDict setValue:[issueRequest responseData] forKey:@"content"];			
		[issuesDict setValue:issueDict forKey:href];
	}		
	return issuesDict;
}

#pragma mark -
#pragma mark Login Methods

- (void) login {
	NSURL * url = [NSURL URLWithString:[self urlString]];
	RMLogin * login = [[RMLogin loginWithURL:url username:[self username] password:[self password]] retain];
	[login setDidFinishSelector:@selector(loginCompleted:)];
	[login setDidFailSelector:@selector(loginFailed:)];
	[login setDidStartSelector:@selector(loginBegan:)];	
	[login setDelegate:self];
	[login startAsynchronous];
}

- (void) loginBegan:(RMLogin *)aLogin {
}

- (void) loginFailed:(RMLogin *)aLogin {
	[self didFailWithError:[aLogin error]];
}

- (void) loginCompleted:(RMLogin *)aLogin {	
	// extract feed urls for "my page"
	TFHpple * myPageParser = [[[TFHpple alloc] initWithHTMLData:[aLogin responseData]] autorelease];
	NSArray * feeds = [myPageParser search:@"//link[@type='application/atom+xml']"];
	NSMutableDictionary * feedDicts = [NSMutableDictionary dictionary];
	for (TFHppleElement * feed in feeds) 
	{
		// Caching into response dictionary
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[feed objectForKey:@"title"],@"title",[feed objectForKey:@"href"],@"href",nil];
		[feedDicts setValue:dict forKey:[feed objectForKey:@"href"]];
	}
	[responseDictionary setValue:feedDicts forKey:@"myPage"];
	
	[self fetchMyPageFeedsWithCookies:[aLogin responseCookies]];
}

#pragma mark -
#pragma mark Fetching My Page

- (void) fetchMyPageFeedsWithCookies:(NSArray *)cookies {	
	NSMutableDictionary * myPage = [[responseDictionary valueForKey:@"myPage"] mutableCopy];
	for (NSDictionary * feed in [myPage allValues]) 
	{
		NSURL * feedURL = [NSURL URLWithString:[feed valueForKey:@"href"] relativeToURL:[NSURL URLWithString:[self urlString]]];
		NSError * err;
		NSDictionary * issuesDict = [self issuesWithURL:feedURL cookies:&cookies error:&err];
		if (err) return [self didFailWithError:err];
		
		// Caching into response dictionary
		NSMutableDictionary * dict = [feed mutableCopy];
		[dict setValue:issuesDict forKey:@"issues"];
		[myPage setValue:dict forKey:[feed objectForKey:@"href"]];
	}
	[responseDictionary setValue:myPage forKey:@"myPage"];
	
	[self fetchProjectsPageWithCookies:cookies];
}

#pragma mark -
#pragma mark Fetching Projects

- (void) fetchProjectsPageWithCookies:(NSArray *)cookies {
	NSString * href = [responseDictionary valueForKeyPath:@"projects.href"];
	if (href != nil) 
		return [self fetchProjectsFeedWithCookies:cookies];
	
	NSURL * url = [NSURL URLWithString:@"projects" relativeToURL:[NSURL URLWithString:[self urlString]]];
	[[self requestWithURL:url cookies:cookies startSelector:@selector(fetchProjectsPageBegan:) finishSelector:@selector(fetchProjectsPageCompleted:) failSelector:@selector(fetchProjectsPageFailed:)] startAsynchronous];
}

- (void) fetchProjectsPageBegan:(ASIHTTPRequest *)aRequest {
	NSLog(@"fetching projects page on: %@",[aRequest url]);
}

- (void) fetchProjectsPageFailed:(ASIHTTPRequest *)aRequest {
	NSLog(@"fetching projects page failed: %@",[[aRequest error] localizedDescription]);
	[self didFailWithError:[aRequest error]];
}

- (void) fetchProjectsPageCompleted:(ASIHTTPRequest *)aRequest {
	// extract feed url
	TFHpple * xpathParser = [[[TFHpple alloc] initWithHTMLData:[aRequest responseData]] autorelease];
	NSString *href = [[xpathParser at:@"//a[@class='atom' or @class='feed']"] objectForKey:@"href"];
	if (href == nil) {
		NSDictionary * userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"RMProjectsFeedNotFound","Couldn't found projects feed. Please check login and password.") forKey:NSLocalizedDescriptionKey];
		NSError * err = [NSError errorWithDomain:@"RMProjectsFeedNotFound" code:1 userInfo:userInfo];
		return [self didFailWithError:err];
	}
	
	[responseDictionary setValue:[NSMutableDictionary dictionaryWithObject:href forKey:@"href"] forKey:@"projects"];
	
	[self fetchProjectsFeedWithCookies:[aRequest responseCookies]];
}

- (void) fetchProjectsFeedWithCookies:(NSArray *)cookies {
	NSURL * url = [NSURL URLWithString:[responseDictionary valueForKeyPath:@"projects.href"] relativeToURL:[NSURL URLWithString:[self urlString]]];
	[[self requestWithURL:url cookies:cookies startSelector:@selector(fetchProjectsFeedBegan:) finishSelector:@selector(fetchProjectsFeedCompleted:) failSelector:@selector(fetchProjectsFeedFailed:)] startAsynchronous];
}

- (void) fetchProjectsFeedBegan:(ASIHTTPRequest *)aRequest {
	NSLog(@"fetching projects feed on: %@",[aRequest url]);
}

- (void) fetchProjectsFeedFailed:(ASIHTTPRequest *)aRequest {
	NSLog(@"fetching projects feed failed: %@",[[aRequest error] localizedDescription]);
	[self didFailWithError:[aRequest error]];
}

- (void) fetchProjectsFeedCompleted:(ASIHTTPRequest *)aRequest {	
	NSArray * cookies = [aRequest responseCookies];

	TFHpple * feedParser = [[[TFHpple alloc] initWithHTMLData:[aRequest responseData]] autorelease];
	NSArray * entries = [feedParser search:@"//feed/entry"];
	NSMutableDictionary * feedDicts = [NSMutableDictionary dictionary];
		
	for (int i = 1; i <= [entries count]; i++) 
	{
		NSString * href = [[feedParser at:[NSString stringWithFormat:@"//feed/entry[%d]/link", i]] objectForKey:@"href"];
		NSURL * projectURL = [NSURL URLWithString:href relativeToURL:[NSURL URLWithString:[self urlString]]];
		ASIHTTPRequest * projectRequest = [self requestWithURL:projectURL cookies:cookies startSelector:nil finishSelector:nil failSelector:nil];
		[projectRequest startSynchronous];
		cookies = [projectRequest responseCookies];
				
		if ([projectRequest error]) {
			[self didFailWithError:[projectRequest error]];
			return;
		}
		
		// Fetch activity
		TFHpple * projectParser = [[[TFHpple alloc] initWithHTMLData:[projectRequest responseData]] autorelease];
		NSString * activityLink = [[projectParser at:@"//link[@type='application/atom+xml']"] objectForKey:@"href"];
		NSURL * activityURL = [NSURL URLWithString:activityLink relativeToURL:[NSURL URLWithString:[self urlString]]];
		NSError * activityError;
		NSDictionary * activityDict = [self issuesWithURL:activityURL cookies:&cookies error:&activityError];
		if (activityError) 
			return [self didFailWithError:activityError];
		
		// Fetch issues page
		NSString * issuesPageLink = [[projectParser at:@"//a[@class='issues']"] objectForKey:@"href"];		
		NSURL * issuesPageURL = [NSURL URLWithString:issuesPageLink relativeToURL:[NSURL URLWithString:[self urlString]]];
		ASIHTTPRequest * issuesPageRequest = [self requestWithURL:issuesPageURL cookies:cookies startSelector:nil finishSelector:nil failSelector:nil];
		[issuesPageRequest startSynchronous];
		cookies = [issuesPageRequest responseCookies];
		
		if ([issuesPageRequest error])
			return [self didFailWithError:[issuesPageRequest error]];
		
		// Fetch issues
		TFHpple * issuesPageParser = [[[TFHpple alloc] initWithHTMLData:[issuesPageRequest responseData]] autorelease];
		NSString * issuesLink = [[issuesPageParser at:@"//link[@type='application/atom+xml']"] objectForKey:@"href"];
		NSURL * issuesURL = [NSURL URLWithString:issuesLink relativeToURL:[NSURL URLWithString:[self urlString]]];
		NSError * issuesError;
		NSDictionary * issuesDict = [self issuesWithURL:issuesURL cookies:&cookies error:&issuesError];
		if (issuesError) 
			return [self didFailWithError:issuesError];
		
		// creating data structure to response		
		NSMutableDictionary * dict = [NSMutableDictionary dictionary];
		[dict setValue:href			forKey:@"href"];
		[dict setValue:issuesDict	forKey:@"issues"];
		[dict setValue:activityDict forKey:@"activity"];
		[dict setValue:[[feedParser at:[NSString stringWithFormat:@"//feed/entry[%d]/title", i]] content] forKey:@"title"];
		[dict setValue:[[feedParser at:[NSString stringWithFormat:@"//feed/entry[%d]/updated", i]] content] forKey:@"updated"];
		[dict setValue:[[feedParser at:[NSString stringWithFormat:@"//feed/entry[%d]/content", i]] content] forKey:@"content"];
		[feedDicts setValue:dict forKey:href];
	}
	
	[responseDictionary setValue:feedDicts forKeyPath:@"projects.content"];
	
	[self didFinish];
}

@end
