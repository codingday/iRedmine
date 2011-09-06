//
//  IssueTableController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "RESTRequest.h"
#import "Account.h"
#import "Login.h"
#import "NSStringAdditions.h"
#import "CSRegex.h"
#import "NSDateAdditions.h"
#import "AtomFeed.h"

@interface IssueTableController : BaseTableViewController <TTURLRequestDelegate> {
	RESTRequest * _request;
	Login * _login;
	AtomFeed * _atomFeed;
}

@end
