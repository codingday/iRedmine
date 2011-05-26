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
#import "NSStringAdditions.h"
#import "CSRegex.h"
#import "NSDateAdditions.h"

@interface IssueTableController : BaseTableViewController {
	RESTRequest * _request;
}

@property(nonatomic, retain, readonly) RESTRequest * request;

@end
