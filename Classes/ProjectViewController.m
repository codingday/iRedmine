//
//  ProjectViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 14.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "ProjectViewController.h"

@implementation ProjectViewController

@synthesize project;
@synthesize homeItem;
@synthesize issuesItem;
@synthesize activityItem;
@synthesize titleLabel;
@synthesize dateLabel;
@synthesize descriptionText;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	NSString * content = [project valueForKey:@"content"];
	[descriptionText loadHTMLString:[content stringByUnescapingHTML] baseURL:nil];
	
	int issuesCount = [[project valueForKey:@"issues"] count];
	if (issuesCount > 0) {
		[issuesItem setBadgeValue:[NSString stringWithFormat:@"%d",issuesCount]];
	} else {
		[issuesItem setBadgeValue:nil];
	}

	int activityCount = [[project valueForKey:@"activity"] count];
	if (activityCount > 0) {
		[activityItem setBadgeValue:[NSString stringWithFormat:@"%d",activityCount]];
	} else {
		[activityItem setBadgeValue:nil];
	}
	
	NSDate * date = [NSDate dateFromRedmineString:[project valueForKey:@"updated"]];
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];	
	[dateLabel setText:[dateFormatter stringFromDate:date]];
	
	[self setTitle:[[[project valueForKey:@"title"] componentsSeparatedByString:@" - "] objectAtIndex:0]];	
	[titleLabel setText:[[[project valueForKey:@"title"] componentsSeparatedByString:@" - "] objectAtIndex:1]];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supporting all orientations
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	if(item == homeItem){
		[self.navigationController popToRootViewControllerAnimated:YES];
	} else if((item == issuesItem) && ([[issuesItem badgeValue] intValue] > 0))	{
		IssueTableController * issuesViewController = [IssueTableController initWithArray:[project valueForKey:@"issues"] title:NSLocalizedString(@"Issues",@"Issues")];		
		[self.navigationController pushViewController:issuesViewController animated:YES];			
	} else if((item == activityItem) && ([[activityItem badgeValue] intValue] > 0))	{
		IssueTableController * activityViewController = [IssueTableController initWithArray:[project valueForKey:@"activity"] title:NSLocalizedString(@"Activities",@"Activities")];
		[self.navigationController pushViewController:activityViewController animated:YES];
	}
	[tabBar setSelectedItem:nil];
}

- (void)dealloc {
	[project release];
	[descriptionText release];
	[homeItem release];
	[issuesItem release];
	[activityItem release];
	[titleLabel release];
	[dateLabel release];
	
    [super dealloc];
}


@end
