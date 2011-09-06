//
//  NSDateAdditions.m
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "NSDateAdditions.h"


@implementation NSDate (NSDateAdditions)

+ (NSDate *)dateFromXMLString:(NSString *)string{
	NSString * normalizedString = [string stringByReplacingOccurrencesOfString:@":" withString:@""];
	return [NSDate dateFromString:normalizedString withFormat:@"yyyy-MM-dd'T'HHmmssz"];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format{
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:format];
	return [dateFormatter dateFromString:string];
}

@end
