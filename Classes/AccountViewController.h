//
//  AccountViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 21.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "RESTRequest.h"
#import "NSStringAdditions.h"
#import "Account.h"
#import "Login.h"
#import "AtomFeed.h"

@interface AccountViewController : BaseTableViewController <TTURLRequestDelegate> {
	Login * _login;
	RESTRequest * _request;
	AtomFeed * _atomFeed;
}

@end
