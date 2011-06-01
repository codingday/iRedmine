//
//  RMConnector.h
//  Hpple
//
//  Created by Frank Wittig on 06.05.10.
//  Copyright 2010 Frank Wittig <frank@lintuxhome.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"TFHpple.h"

@interface RMConnector : NSObject {
	NSString	* _URLString;
	
	NSMutableDictionary * _response;
	
	// The delegate, you need to manage setting and talking to your delegate in your subclasses
	id _delegate;
	
	// Called on the delegate when the connector starts
	SEL _didStartSelector;
	
	// Called on the delegate when the connector completes successfully
	SEL _didFinishSelector;
	
	// Called on the delegate when the connector fails
	SEL _didFailSelector;	
	
	// If an error occurs, error will contain an NSError
	NSError * _error;	
}

@property(retain) NSString *URLString;
@property(retain,readonly) NSMutableDictionary *response;
@property(assign) id delegate;
@property(assign) SEL didStartSelector;
@property(assign) SEL didFinishSelector;
@property(assign) SEL didFailSelector;
@property(retain, readonly) NSError *error;

// Convenience constructors
+ (id) connectorWithURL:(NSString *)URLString;
- (id) initWithURL:(NSString *)URLString;

- (void) start;
- (void) cancel;

@end
