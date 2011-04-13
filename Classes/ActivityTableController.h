//
//  ActivityTableController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "RMConnector.h"
#import "CSRegex.h"
#import "NSDateAdditions.h"

@interface ActivityTableController : BaseTableViewController {
	RMConnector * _connector;
}

@property(nonatomic, retain, readonly) RMConnector * connector;

@end
