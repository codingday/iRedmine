//
//  MyPageTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 12.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "MyPageTableController.h"


@implementation MyPageTableController

#pragma mark -
#pragma mark Connector

- (void)didFinishConnect:(RMConnector*)connector {
	NSString * myPageURL = [[self query] valueForKey:@"mypage"];
	
	NSDictionary * myPageDict = [[connector responseDictionary] valueForKey:@"myPage"];
	NSDictionary * feedDict = [myPageDict valueForKey:myPageURL];
	NSDictionary * issuesDict = [feedDict valueForKey:@"issues"];
	[self performSelector:@selector(update:) withObject:issuesDict];
}

@end
