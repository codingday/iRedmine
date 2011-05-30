//
//  Account.m
//  iRedmine
//
//  Created by Thomas Stägemann on 30.05.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "Account.h"


@implementation Account

@synthesize URLString=_URLString;
@synthesize username=_username;
@synthesize password=_password;

+ (id)accountWithURL:(NSString*)url username:(NSString*)user password:(NSString*)pwd {
	return [[[Account alloc] initWithURL:url username:user password:pwd] autorelease];
}

+ (id)accountWithURL:(NSString*)url {
	return [[[Account alloc] initWithURL:url] autorelease];
}

- (id)initWithURL:(NSString*)url username:(NSString*)user password:(NSString*)pwd {
	if (self = [super init]) {
		[self setURLString:url];
		if (![user isEmptyOrWhitespace])
			[self setUsername:user];
		if (![pwd isEmptyOrWhitespace])
			[self setPassword:pwd];
	}
	return self;
}

- (id)initWithURL:(NSString*)url {
	NSURL * URL = [NSURL URLWithString:url];
	if (!URL) return nil;
	
	NSURLProtectionSpace * protectionSpace = [NSURLProtectionSpace protectionSpaceWithURL:URL];
	NSURLCredentialStorage * storage = [NSURLCredentialStorage sharedCredentialStorage];
	NSDictionary * dict = [storage credentialsForProtectionSpace:protectionSpace];
	if (!dict)
		return [self initWithURL:url username:nil password:nil];
	
	NSURLCredential * credential = [[dict allValues] objectAtIndex:0];
	return [self initWithURL:url username:[credential user] password:[credential password]];
}

- (void)save {
	NSURL * URL = [NSURL URLWithString:_URLString];
	if (!URL) return;
	
	if (_username && ![_username isEmptyOrWhitespace] && _password && ![_password isEmptyOrWhitespace]) {
		NSURLProtectionSpace * protectionSpace = [NSURLProtectionSpace protectionSpaceWithURL:URL];
		NSURLCredentialStorage * storage = [NSURLCredentialStorage sharedCredentialStorage];	
		NSURLCredential * credential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistencePermanent];
		[storage setCredential:credential forProtectionSpace:protectionSpace];
	}
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray * accounts = [[defaults arrayForKey:@"accounts"] mutableCopy];
	if (![accounts containsObject:_URLString])
		[accounts addObject:_URLString];
	[defaults setObject:accounts forKey:@"accounts"];
	[defaults synchronize];	
}

- (void)remove {
	NSURL * URL = [NSURL URLWithString:_URLString];
	if (!URL) return;

	NSURLProtectionSpace * protectionSpace = [NSURLProtectionSpace protectionSpaceWithURL:URL];
	NSURLCredentialStorage * storage = [NSURLCredentialStorage sharedCredentialStorage];
	NSDictionary * dict = [storage credentialsForProtectionSpace:protectionSpace];
	for (NSURLCredential * credential in [dict allValues])
		[storage removeCredential:credential forProtectionSpace:protectionSpace];
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray * accounts = [[defaults arrayForKey:@"accounts"] mutableCopy];
	if ([accounts containsObject:_URLString])
		[accounts removeObject:_URLString];
	[defaults setValue:accounts forKey:@"accounts"];
	[defaults synchronize];
}

@end
