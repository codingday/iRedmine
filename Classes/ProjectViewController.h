//
//  ProjectViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 14.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "RMConnector.h"
#import "Constants.h"

@interface ProjectViewController : BaseTableViewController {
	RMConnector * _connector;
}

@property(nonatomic, retain, readonly) RMConnector * connector;

- (IBAction)reloadData:(id)sender;

@end
