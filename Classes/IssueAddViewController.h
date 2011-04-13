//
//  IssueAddViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"

@interface IssueAddViewController : BaseTableViewController <TTURLRequestDelegate> {

}

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

@end
