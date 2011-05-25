//
//  AccountsDataSource.m
//  iRedmine
//
//  Created by Thomas Stägemann on 07.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "AccountsDataSource.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AccountsTableViewDelegate


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
	id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
	
	id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	Class cls = [dataSource tableView:tableView cellClassForObject:object];
	return [cls tableView:tableView rowHeightForObject:object];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
	TTTableTextItem * object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	
	if ([[object URL] isEqualToString:@"iredmine://account/add"]) 
		return UITableViewCellEditingStyleInsert;
	return UITableViewCellEditingStyleDelete;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation AccountsModel

@synthesize accounts = _accounts;

#pragma mark -
#pragma mark Initialization

- (id)init {
	if (self = [super init]) {
		_accounts = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"accounts"] retain];
		_delegates = nil;
	}
	return self;
}

- (void)search:(NSString*)text {
	[self cancel];
	
	[_delegates perform:@selector(modelDidStartLoad:) withObject:self];
	
	NSArray * savedAccounts = [[NSUserDefaults standardUserDefaults] arrayForKey:@"accounts"];

	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",text];
	_accounts = [[savedAccounts filteredArrayUsingPredicate:predicate] retain];
	
	[_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
	[_delegates perform:@selector(modelDidChange:) withObject:self];
}

- (void)removeAccountWithIndex:(NSUInteger)index {
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray * savedAccounts =  [[defaults arrayForKey:@"accounts"] mutableCopy];
	[savedAccounts removeObjectAtIndex:index];
	[defaults setValue:savedAccounts forKey:@"accounts"];
	[defaults synchronize];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	TT_RELEASE_SAFELY(_delegates);
	TT_RELEASE_SAFELY(_accounts);
	[super dealloc];
}

#pragma mark -
#pragma mark Model

- (NSMutableArray*)delegates {
	if (!_delegates) {
		_delegates = TTCreateNonRetainingArray();
	}
	return _delegates;
}

- (BOOL)isLoadingMore {
	return NO;
}

- (BOOL)isOutdated {
	return NO;
}

- (BOOL)isLoaded {
	return !!_accounts;
}

- (BOOL)isLoading {
	return NO;
}

- (BOOL)isEmpty {
	return ![_accounts count];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AccountsDataSource

@synthesize accountsModel = _accountsModel;

#pragma mark -
#pragma mark Initialization

- (id)init {
	if (self = [super init]) {
		_urlFormat = [@"iredmine://account?url=%@" retain];
		_accountsModel = [[[AccountsModel alloc] init] retain];
		[self setModel:_accountsModel];
	}
	return self;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	TT_RELEASE_SAFELY(_accountsModel);
	TT_RELEASE_SAFELY(_urlFormat);
	[super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (void)tableViewDidLoadModel:(UITableView*)tableView {
	[self setItems:[NSMutableArray array]];
	[self setSections:[NSMutableArray arrayWithObject:NSLocalizedString(@"Accounts",@"")]];
	
	NSMutableArray * accounts = [NSMutableArray array];
	for (NSString * account in [_accountsModel accounts]) {
		NSURL * url = [NSURL URLWithString:account];
		NSURLProtectionSpace *protectionSpace = [NSURLProtectionSpace protectionSpaceWithURL:url];
		NSString * username = NSLocalizedString(@"Anonymous",@"");
		NSDictionary * credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
		if (credentials)
			username = [(NSURLCredential*)[[credentials allValues] objectAtIndex:0] user];
		NSString * subtitle = [NSString stringWithFormat:NSLocalizedString(@"Username: %@",@""),username];
		NSString * URLString = [NSString stringWithFormat:_urlFormat,account];
		[accounts addObject:[TTTableSubtitleItem itemWithText:account subtitle:subtitle URL:URLString]];
	}
	[_items addObject:accounts];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AccountsEditingDataSource

#pragma mark -
#pragma mark Initialization

- (id)init {
	if (self = [super init]) {
		_urlFormat = [@"iredmine://account/edit?url=%@" retain];
	}
	return self;
}


#pragma mark -
#pragma mark Table view data source

- (void)tableViewDidLoadModel:(UITableView*)tableView {	
	[super tableViewDidLoadModel:tableView];
	
	NSString * text = NSLocalizedString(@"Add new account ...",@"");
	TTTableTextItem * item = [TTTableTextItem itemWithText:text URL:@"iredmine://account/add"];
	[_items addObject:[NSMutableArray arrayWithObject:item]];
	[_sections addObject:@""];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[tableView beginUpdates];
		[self removeItemAtIndexPath:indexPath];
		[(AccountsModel*)[self model] removeAccountWithIndex:[indexPath row]];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade]; 
		[tableView endUpdates]; 
	}
}

@end
