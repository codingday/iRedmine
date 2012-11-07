//
//  IssueViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 06.09.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "NSStringAdditions.h"
#import "NSDateAdditions.h"
#import "RESTRequest.h"
#import "Account.h"
#import "Login.h"
#import "CSRegex.h"

@interface IssueViewController : BaseTableViewController <TTURLRequestDelegate> {
	Login * _login;
	RESTRequest * _request;
}

@end
