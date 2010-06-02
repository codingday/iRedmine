//
//  RMLogin.h
//  iRedmine
//
//  Created by Thomas Stägemann on 02.06.10.
//  Copyright 2010 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "TFHpple.h"


@interface RMLogin : NSObject {
	ASIFormDataRequest * loginRequest;
	ASIHTTPRequest * fetchRequest;
	NSURL * backURL;
		
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

@property(retain, nonatomic) NSURL * backURL;
@property(assign) id delegate;
@property(assign) SEL didStartSelector;
@property(assign) SEL didFinishSelector;
@property(assign) SEL didFailSelector;
@property(retain, readonly) NSError *error;

// Convenience constructors
+ (id) loginWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password;
- (id) initWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password;

- (NSString *)responseString;
- (NSData *)responseData;
- (NSArray *)responseCookies;

- (void) startAsynchronous;
- (void) cancel;

@end
