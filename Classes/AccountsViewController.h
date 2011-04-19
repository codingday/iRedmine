//
//  AccountsViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "AccountsDataSource.h"

@interface AccountsViewController : BaseTableViewController {
	UIBarButtonItem * _storeButton;
	UIBarButtonItem * _addButton;
}

@end
