//
//  AccountEditViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 07.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "AccountEditViewController.h"


@implementation AccountEditViewController

- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self setTitle:NSLocalizedString(@"Edit account",@"")];
	}
	return self;
}

@end
