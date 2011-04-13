//
//  AccountsViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "AccountsViewController.h"

@implementation AccountsViewController

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];			
	[[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
	[[self tableView] setAllowsSelectionDuringEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
	if ([self isEditing]) 
		[self setDataSource:[[[AccountsEditingDataSource alloc] init] autorelease]];
	else
		[self setDataSource:[[[AccountsDataSource alloc] init] autorelease]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (editing) {
		UIBarButtonItem * addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
		[[self navigationItem] setRightBarButtonItem:addButton animated:YES];
		[self setDataSource:[[[AccountsEditingDataSource alloc] init] autorelease]];
	}
	else {
		[[self navigationItem] setRightBarButtonItem:nil animated:YES];
		[self setDataSource:[[[AccountsDataSource alloc] init] autorelease]];
	}
}

- (id<UITableViewDelegate>)createDelegate {
	return [[[AccountsTableViewDelegate alloc] initWithController:self] autorelease];
}

- (void)add:(id)sender {
	[self openURL:@"iredmine://account/add"];
}

@end

