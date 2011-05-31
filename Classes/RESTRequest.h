//
//  RESTRequest.h
//  iRedmine
//
//  Created by Thomas Stägemann on 13.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/encoding.h>
#import <libxml/xmlwriter.h>
#import "Account.h"
#import "Login.h"

@interface RESTRequest : TTURLRequest {
	NSDictionary * _dictionary;
}

@property(nonatomic, retain) NSDictionary * dictionary;

@end
