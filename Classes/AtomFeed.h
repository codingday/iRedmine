//
//  AtomFeed.h
//  iRedmine
//
//  Created by Thomas Stägemann on 01.06.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSStringAdditions.h"
#import	"TFHpple.h"
#import "NSURLRequestAdditions.h"

@interface AtomFeed : NSObject {
	NSString * _URL;
	NSString * _path;
	NSString * _xPath;
	
	TTURLRequest * _pageRequest;
	TTURLRequest * _feedRequest;

	// The delegate, you need to manage setting and talking to your delegate in your subclasses
	id _delegate;
	
	// Called on the delegate when the fetch starts
	SEL _didStartSelector;
	
	// Called on the delegate when the fetch was successful
	SEL _didFinishSelector;
	
	// Called on the delegate when the fetch fails
	SEL _didFailSelector;	
	
	// If an error occurs, error will contain an NSError
	NSError * _error;		
}

@property(nonatomic, retain) NSString * URL;
@property(nonatomic, retain) NSString * path;
@property(nonatomic, retain) NSString * xPath;
@property(assign) id delegate;
@property(assign) SEL didStartSelector;
@property(assign) SEL didFinishSelector;
@property(assign) SEL didFailSelector;
@property(retain, readonly) NSError *error;


- (id)initWithURL:(NSString*)baseURL path:(NSString*)relativePath xPath:(NSString*)xPath;
- (NSDictionary *)response;
- (void)fetch;

@end
