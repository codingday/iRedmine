//
//  NSDateAdditions.h
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (NSDateAdditions)

+ (NSDate *)dateFromXMLString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

@end
