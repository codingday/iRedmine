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
#import "RESTRequest.h"
#import "Account.h"
#import "Login.h"
#import "AtomFeed.h"
#import "CSRegex.h"
#import "TimeInformationRequest.h"

@interface ProjectViewController : BaseTableViewController <TTURLRequestDelegate, TimeInformationDelegate> {
	Login * _login;
	RESTRequest * _request;
	AtomFeed * _atomFeed;
	
	TimeInformationRequest * _timeInfo;
}


@end
