//
//  NSURLProtectionSpaceAdditions.h
//  iRedmine
//
//  Created by Thomas Stägemann on 25.05.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURLProtectionSpace (NSURLProtectionSpaceAdditions)

+ (id)protectionSpaceWithURL:(NSURL*)URL;

@end
