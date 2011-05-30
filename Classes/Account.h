//
//  Account.h
//  iRedmine
//
//  Created by Thomas Stägemann on 30.05.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSURLProtectionSpaceAdditions.h"

@interface Account : NSObject {
	NSString * _URLString;
	NSString * _username;
	NSString * _password;
}

@property(nonatomic,retain) NSString * URLString;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;
		  
+ (id)accountWithURL:(NSString*)url username:(NSString*)user password:(NSString*)pwd;
+ (id)accountWithURL:(NSString*)url;

- (id)initWithURL:(NSString*)url username:(NSString*)user password:(NSString*)pwd;
- (id)initWithURL:(NSString*)url;

- (void)save;
- (void)remove;

@end
