//
//  ProjectTableController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 21.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeCell.h"
#import "ProjectViewController.h"
#import "IssueTableController.h"
#import "NSDateAdditions.h"

@interface ProjectTableController : UITableViewController 
{
	NSDictionary * accountDict;
	UITableView * projectTable;
	ProjectViewController * projectViewController;
	BadgeCell * badgeCell;
}

@property(nonatomic,retain) NSDictionary * accountDict;
@property(nonatomic,retain) IBOutlet UITableView * projectTable;
@property(nonatomic,retain) ProjectViewController * projectViewController;
@property(nonatomic,retain) IBOutlet BadgeCell * badgeCell;

@end
