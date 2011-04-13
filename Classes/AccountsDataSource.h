//
//  AccountsDataSource.h
//  iRedmine
//
//  Created by Thomas Stägemann on 07.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountsTableViewDelegate : TTTableViewDelegate {
	
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
@interface AccountsModel : NSObject <TTModel> {
	NSArray * _accounts;
	NSMutableArray* _delegates;
}

@property(nonatomic,retain) NSArray * accounts;

- (void)search:(NSString*)text;
- (void)removeAccountWithIndex:(NSUInteger)index;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@interface AccountsDataSource : TTSectionedDataSource {
	NSString * _urlFormat;
	AccountsModel * _accountsModel;
}

@property(nonatomic,readonly) AccountsModel * accountsModel;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@interface AccountsEditingDataSource : AccountsDataSource <UITableViewDelegate> {
}

@end
