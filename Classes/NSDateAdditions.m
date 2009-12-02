//
//  NSDateAdditions.m
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "NSDataAdditions.h"


@implementation NSDate (NSDateAdditions)

+ (NSDate *)dataFromRedmineString:(NSString *)string{
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
	return [dateFormatter dateFromString:string];
}

@end
