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

@interface AccountViewController : BaseTableViewController {
	RESTRequest * _request;
}

@property(nonatomic, retain, readonly) RESTRequest * request;

@end
