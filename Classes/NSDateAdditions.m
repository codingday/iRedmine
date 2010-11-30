//
//  NSDateAdditions.m
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "NSDateAdditions.h"


@implementation NSDate (NSDateAdditions)

+ (NSDate *)dateFromRedmineString:(NSString *)string{
	NSString * normalizedString = [string stringByReplacingOccurrencesOfString:@":" withString:@""];
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmssz"];
	return [dateFormatter dateFromString:normalizedString];
}

@end
