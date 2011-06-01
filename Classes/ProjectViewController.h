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
#import "Constants.h"
#import "RESTRequest.h"
#import "Account.h"
#import "Login.h"

@interface ProjectViewController : BaseTableViewController {
	Login * _login;
	RESTRequest * _request;
}

- (IBAction)reloadData:(id)sender;

@end
