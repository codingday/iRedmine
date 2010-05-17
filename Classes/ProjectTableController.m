//
//  ProjectTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 21.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "ProjectTableController.h"


@implementation ProjectTableController

@synthesize accountDict;
@synthesize projectTable;
@synthesize projectViewController;
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
	
	NSURL * url = [NSURL URLWithString:[accountDict valueForKey:@"url"]];
	[self setTitle:[url host]];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray * myPage = [accountDict valueForKeyPath:@"data.myPage"];

	switch (section) {
		case 0:
			if (myPage && [myPage count] > 0) 
				return NSLocalizedString(@"My Page",@"My Page"); 
		case 1:	
			return NSLocalizedString(@"Projects",@"Projects");
		default: 
			return nil;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSDictionary * myPage = [accountDict valueForKeyPath:@"data.myPage"];

	if (myPage && [myPage count] > 0) 
		return 2;
	
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray * myPage = [accountDict valueForKeyPath:@"data.myPage"];

	switch (section) {
		case 0:  
			// My Page
			if (myPage && [myPage count] > 0) 
				return 2; 
		case 1:	 
			// Projects
			return [[accountDict valueForKeyPath:@"data.projects.content"] count]; 
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

	NSDictionary * myPage = [accountDict valueForKeyPath:@"data.myPage"];

	// Set up the cell...
	switch (indexPath.section){
		case 0:  
			// My Page
			if (myPage && [myPage count] > 0) {
				NSDictionary * dict = [[myPage allValues] objectAtIndex:indexPath.row];
				[badgeCell setCellDataWithTitle:[dict valueForKey:@"title"] subTitle:nil];
				[badgeCell setAccessoryType:UITableViewCellAccessoryNone];

				NSArray * issues = [dict valueForKey:@"content"];
				if (issues && [issues count] > 0) {
					[badgeCell setBadge:[issues count]];
					[badgeCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				}
				break;
			}
		case 1:	 
			// Projects
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			
			NSDictionary * projects = [accountDict valueForKeyPath:@"data.projects.content"];
			NSDictionary * project = [[projects allValues] objectAtIndex:indexPath.row];
			
			NSDate * date = [NSDate dateFromRedmineString:[project valueForKey:@"updated"]];
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
	NSDictionary * myPage = [accountDict valueForKeyPath:@"data.myPage"];

	switch (indexPath.section){
		case 0:
			// My Page
			if (myPage && [myPage count] > 0) {
				NSDictionary * dict = [[myPage allValues] objectAtIndex:indexPath.row];
				NSArray * issues = [[dict valueForKey:@"content"] allValues];
				if (issues && [issues count] > 0) { 
					IssueTableController * issuesViewController = [IssueTableController initWithArray:issues title:[dict valueForKey:@"title"]];
					[self.navigationController pushViewController:issuesViewController animated:YES];
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
			
			NSDictionary * projects = [accountDict valueForKeyPath:@"data.projects.content"];
			NSDictionary * project = [[projects allValues] objectAtIndex:indexPath.row];
			
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
	[badgeCell release];	
    [super dealloc];
}


@end

