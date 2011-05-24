//
//  NSStringAdditions.h
//  iRedmine
//
//  Created by Thomas Stägemann on 02.12.09.
//  Copyright 2009 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSStringAdditions)

- (NSString *)stringByAppendingURLPathComponent:(NSString*)component;
- (NSString *)stringByEscapingHTML;
- (NSString *)stringByUnescapingHTML;

@end
