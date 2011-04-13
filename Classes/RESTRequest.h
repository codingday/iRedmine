//
//  RESTRequest.h
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RESTRequest : NSObject {
	NSString * _URL;
	NSDictionary * _options;
}

@property(nonatomic, retain) NSString * URL;
@property(nonatomic, retain) NSDictionary * options;

+ (id)requestWithURL:(NSString *)URLString options:(NSDictionary *)options;
+ (id)requestWithURL:(NSString *)URLString;
- (id)initWithURL:(NSString *)URLString options:(NSDictionary *)options;
- (id)initWithURL:(NSString *)URLString;

@end
