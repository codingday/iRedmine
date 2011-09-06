//
//  IssueNotesViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 06.09.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "NSStringAdditions.h"
#import "RESTRequest.h"
#import "Account.h"
#import "Login.h"

@interface IssueNotesViewController : BaseTableViewController <TTURLRequestDelegate> {
	RESTRequest * _request;
	Login * _login;
	TTTextEditor * _notesEditor;
}

- (IBAction)send:(id)sender;
- (IBAction)cancel:(id)sender;

@end
