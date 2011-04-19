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

	_addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] retain];
	_storeButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Store",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(openStore:)] retain];
	if ([SKPaymentQueue canMakePayments])
		[[self navigationItem] setRightBarButtonItem:_storeButton animated:YES];
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
		[[self navigationItem] setRightBarButtonItem:_addButton animated:YES];
		[self setDataSource:[[[AccountsEditingDataSource alloc] init] autorelease]];
	}
	else if ([SKPaymentQueue canMakePayments]){
		[[self navigationItem] setRightBarButtonItem:_storeButton animated:YES];
		[self setDataSource:[[[AccountsDataSource alloc] init] autorelease]];
	}
	else {
		[[self navigationItem] setRightBarButtonItem:nil animated:YES];
		[self setDataSource:[[[AccountsDataSource alloc] init] autorelease]];
	}
}

- (id<UITableViewDelegate>)createDelegate {
	return [[[AccountsTableViewDelegate alloc] initWithController:self] autorelease];
}

#pragma mark -
#pragma mark Selectors

- (void)add:(id)sender {
	TTOpenURL(@"iredmine://account/add");
}

- (void)openStore:(id)sender {
	TTOpenURL(@"iredmine://store");
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	TT_RELEASE_SAFELY(_addButton);
	TT_RELEASE_SAFELY(_storeButton);

	[super dealloc];
}


@end

