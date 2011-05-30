//
//  ProjectViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 14.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "NSStringAdditions.h"
#import "NSDateAdditions.h"
#import "Account.h"
#import "RESTRequest.h"
#import "Constants.h"

@interface ProjectViewController : BaseTableViewController {
	RESTRequest * _request;
}

@property(nonatomic, retain, readonly) RESTRequest * request;

- (IBAction)reloadData:(id)sender;

@end
