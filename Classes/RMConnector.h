//
//  RMConnector.h
//  Hpple
//
//  Created by Frank Wittig on 06.05.10.
//  Copyright 2010 Frank Wittig <frank@lintuxhome.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"TFHpple.h"
#import "ASIHTTPRequest.h"
#import "RMLogin.h"

@interface RMConnector : NSObject {
	
	NSString	*URLString;
	NSString	*username;
	NSString	*password;
	
	NSMutableDictionary *response;
	
	// The delegate, you need to manage setting and talking to your delegate in your subclasses
	id delegate;
	
	// Called on the delegate when the connector starts
	SEL didStartSelector;
	
	// Called on the delegate when the connector completes successfully
	SEL didFinishSelector;
	
	// Called on the delegate when the connector fails
	SEL didFailSelector;	
	
	// If an error occurs, error will contain an NSError
	NSError *error;	
}

@property(retain) NSString *URLString;
@property(retain) NSString *username;
@property(retain) NSString *password;
@property(retain,readonly) NSMutableDictionary *response;
@property(assign) id delegate;
@property(assign) SEL didStartSelector;
@property(assign) SEL didFinishSelector;
@property(assign) SEL didFailSelector;
@property(retain, readonly) NSError *error;

// Convenience constructors
+ (id) connectorWithURL:(NSString *)URLString username:(NSString *)username password:(NSString *)password;
+ (id) connectorWithURL:(NSString *)URLString;
- (id) initWithURL:(NSString *)URLString username:(NSString *)username password:(NSString *)password;

- (ASIHTTPRequest *)requestWithURL:(NSURL *)url cookies:(NSArray *)cookies startSelector:(SEL)startSelector finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector;

- (void) start;
- (void) cancel;

@end
