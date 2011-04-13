//
//  IssueTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "IssueTableController.h"

@implementation IssueTableController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"Issues", @"")];
		
		NSString * login = [query valueForKey:@"login"];
		NSString * password = [query valueForKey:@"password"];
		if (![login isEmptyOrWhitespace] && ![password isEmptyOrWhitespace]) {
			UIBarButtonItem * addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addIssue:)] autorelease];
			[[self navigationItem] setRightBarButtonItem:addButton];
		}
	}
	return self;
}

#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)addIssue:(id)sender {
	[self openURL:[@"iredmine://issue/add" stringByAddingQueryDictionary:[self query]]];
}

#pragma mark -
#pragma mark Connector

- (void)didFinishConnect:(RMConnector*)connector {
	NSString * projectURL = [[self query] valueForKey:@"project"];
	
	NSDictionary * projectsDict = [[connector responseDictionary] valueForKeyPath:@"projects.content"];
	NSDictionary * projectDict = [projectsDict valueForKey:projectURL];
	NSDictionary * issuesDict = [projectDict valueForKey:@"issues"];
	[self performSelector:@selector(update:) withObject:issuesDict];
}

@end
