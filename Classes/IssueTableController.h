//
//  IssueTableController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdNavigator.h"
#import "SubtitleCell.h"
#import "WebViewController.h"
#import "NSStringAdditions.h"
#import "CSRegex.h"

@interface IssueTableController : UITableViewController {
	UITableView * issuesTable;
	NSArray * _issues;
	UIActivityIndicatorView * activityIndicator;	
	SubtitleCell * subtitleCell;
	WebViewController * webViewController;
}

@property(nonatomic,retain) IBOutlet UITableView * issuesTable;
@property(nonatomic,retain) NSArray * _issues;
@property(nonatomic,retain) UIActivityIndicatorView * activityIndicator;
@property(nonatomic,retain) IBOutlet SubtitleCell * subtitleCell;
@property(nonatomic,retain) WebViewController * webViewController;

+ (id)initWithArray:(NSArray *)array title:(NSString*)title;
- (void)setIssues:(NSArray*)array;
- (IBAction)addIssue:(id)sender;

@end
