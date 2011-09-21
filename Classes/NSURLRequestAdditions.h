//
//  NSURLRequestAdditions.h
//  iRedmine
//
//  Created by Thomas Stägemann on 21.09.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURLRequest (NSURLRequestAdditions)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

@end
