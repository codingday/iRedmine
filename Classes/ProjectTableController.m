//
//  ProjectTableController.m
//  iRedmine
//
//  Created by Thomas St√§gemann on 21.04.09.
//  Copyright 2009 Thomas St√§gemann. All rights reserved.
//

#import "ProjectTableController.h"


@implementation ProjectTableController

@synthesize accountDict;
@synthesize projectTable;
@synthesize projectViewController;
@synthesize reportedIssuesViewController;
@synthesize assignedIssuesViewController;
@synthesize badgeCell;

/*
- (void)viewDidLoad {
    [super viewDidLoad];
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}
*/

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	[projectTable reloadData];
	[self setTitle:[accountDict valueForKey:@"hostname"]];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supporting all orientations
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	NSString * password = [accountDict valueForKey:@"password"];
	NSString * username = [accountDict valueForKey:@"username"];

	switch (section) 
	{
		case 0: 
			if ([password length] > 0 && [username length] > 0) return NSLocalizedString(@"My Page",@"My Page"); 
		case 1:	
			return NSLocalizedString(@"Projects",@"Projects");
		default: 
			return nil;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	NSString * password = [accountDict valueForKey:@"password"];
	NSString * username = [accountDict valueForKey:@"username"];

	if ([password length] > 0 && [username length] > 0) return 2; 
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSString * password = [accountDict valueForKey:@"password"];
	NSString * username = [accountDict valueForKey:@"username"];

	switch (section) {
		case 0:  
			// My Page
			if ([password length] > 0 && [username length] > 0) return 2; 
		case 1:	 
			// Projects
			return [[accountDict valueForKey:@"projects"] count]; 
		default: 
			return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ProjectCell";
    
	badgeCell = (BadgeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (badgeCell == nil)
        [[NSBundle mainBundle] loadNibNamed:@"BadgeCell" owner:self options:nil];

	NSString * password = [accountDict valueForKey:@"password"];
	NSString * username = [accountDict valueForKey:@"username"];

	// Set up the cell...
	switch (indexPath.section){
		case 0:  
			// My Page
			if ([password length] > 0 && [username length] > 0) {
				NSArray * assignedIssues = [accountDict valueForKey:@"assigned"];
				NSArray * reportedIssues = [accountDict valueForKey:@"reported"];

				switch (indexPath.row){
					case 0:
						[badgeCell setCellDataWithTitle:NSLocalizedString(@"Issues assigned to me",@"Issues assigned to me") subTitle:nil];
						[badgeCell setBadge:[assignedIssues count]];
						//NSLog(@"assigned issues: %@",assignedIssues);
						break;
					case 1:
						[badgeCell setCellDataWithTitle:NSLocalizedString(@"Reported issues",@"Reported issues") subTitle:nil];
						[badgeCell setBadge:[reportedIssues count]];
						//NSLog(@"reported issues: %@",reportedIssues);
						break;
					default:
						break;
				}
				break;
			}
		case 1:	 
			// Projects
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			
			NSArray * projects = [accountDict valueForKey:@"projects"];
			NSDictionary * project = [projects objectAtIndex:indexPath.row];
			
			NSDate * date = [NSDate dataFromRedmineString:[project valueForKey:@"updated"]];
			NSString * subtitleWithLabel = [NSString stringWithFormat:NSLocalizedString(@"Last Update: %@",@"Last Update: %@"),[dateFormatter stringFromDate:date]];
			NSString * title = [[[project valueForKey:@"title"] componentsSeparatedByString:@" - "] objectAtIndex:0];
			[badgeCell setCellDataWithTitle:title subTitle:subtitleWithLabel];
			break;
		default: 
			break;
	}
	
	return badgeCell;	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSArray * assignedIssues = [accountDict valueForKey:@"assigned"];
	NSArray * reportedIssues = [accountDict valueForKey:@"reported"];
	NSString * password		 = [accountDict valueForKey:@"password"];
	NSString * username		 = [accountDict valueForKey:@"username"];

	switch (indexPath.section){
		case 0:
			if ([password length] > 0 && [username length] > 0) {
				// My Page
				switch (indexPath.row){
					case 0:
						if ([assignedIssues count] == 0) break;
						
						// Issues assigned to me
						if(self.assignedIssuesViewController == nil)
							self.assignedIssuesViewController = [IssueTableController initWithArray:assignedIssues title:NSLocalizedString(@"Assigned Issues",@"Assigned Issues")];
						
						[self.navigationController pushViewController:self.assignedIssuesViewController animated:YES];
						break;
					case 1:
						if ([reportedIssues count] == 0) break;
						
						// Reported issues
						if(self.reportedIssuesViewController == nil)
							self.reportedIssuesViewController = [IssueTableController initWithArray:reportedIssues title:NSLocalizedString(@"Reported Issues",@"Reported Issues")];
						
						[self.navigationController pushViewController:self.reportedIssuesViewController animated:YES];
						break;
					default:
						break;
				}
				break;
			}
		case 1:
			// Projects
			if(self.projectViewController == nil)
				self.projectViewController = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
			
			// Set up the text view...
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			
			NSArray * projects = [accountDict valueForKey:@"projects"];
			NSDictionary * project = [projects objectAtIndex:indexPath.row];
			
			self.projectViewController.project = project;			
			[self.navigationController pushViewController:self.projectViewController animated:YES];
			break;
		default:
			break;
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)dealloc{
	[accountDict release];
	[projectTable release];
	[projectViewController release];
	[reportedIssuesViewController release];
	[assignedIssuesViewController release];
	[badgeCell release];	
    [super dealloc];
}


@end

