//
//  IssueAddViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "NSStringAdditions.h"
#import "RESTRequest.h"
#import <libxml/encoding.h>
#import <libxml/xmlwriter.h>

@interface IssueAddViewController : BaseTableViewController <TTURLRequestDelegate> {
	RESTRequest * _request;
	UITextField * _subjectField;
	TTTextEditor * _descriptionEditor;
}

@property (nonatomic, retain, readonly) RESTRequest * request;

- (IBAction)send:(id)sender;
- (IBAction)cancel:(id)sender;

@end
