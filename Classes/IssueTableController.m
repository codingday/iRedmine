//
//  IssueTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "IssueTableController.h"

@implementation IssueTableController

@synthesize issuesTable;
@synthesize _issues;
@synthesize activityIndicator;
@synthesize subtitleCell;
@synthesize webViewController;

+ (id)initWithArray:(NSArray *)array title:(NSString*)title{
	IssueTableController * _sharedIssueTableController = [[IssueTableController alloc] initWithNibName:@"IssueTableView" bundle:nil];
	[_sharedIssueTableController setIssues:array];
	[_sharedIssueTableController setTitle:title];
	return _sharedIssueTableController;	
}

- (void)setIssues:(NSArray*)array{
	_issues = [array copy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[issuesTable reloadData];
}

/*
 - (void)viewDidAppear:(BOOL)animated 
{
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
- (void)viewDidLoad 
{
    [super viewDidLoad];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_issues count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSMutableDictionary * issue = [_issues objectAtIndex:indexPath.row];

	NSArray * titleComponents	 = [[issue valueForKey:@"title"] componentsSeparatedByString:@": "];
	NSString * subtitle = [titleComponents objectAtIndex:0];
	NSString * title	= [titleComponents lastObject];
	NSString * author	= [issue valueForKey:@"author.name"];	

	 static NSString *CellIdentifier = @"IssueCell";
    
	subtitleCell = (SubtitleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (subtitleCell == nil){
		NSArray * featureTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FeatureCellTypes"];
		NSString * featurePattern = [NSString stringWithFormat:@".*(%@).*",[featureTypes componentsJoinedByString:@"|"]];
		
		NSArray * revisionTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RevisionCellTypes"];
		NSString * revisionPattern = [NSString stringWithFormat:@".*(%@).*",[revisionTypes componentsJoinedByString:@"|"]];

		NSArray * errorTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ErrorCellTypes"];
		NSString * errorPattern = [NSString stringWithFormat:@".*(%@).*",[errorTypes componentsJoinedByString:@"|"]];
		
		if ([subtitle matchedByPattern:featurePattern options:REG_ICASE]) {
			[[NSBundle mainBundle] loadNibNamed:@"FeatureCell" owner:self options:nil];
		} else if ([subtitle matchedByPattern:revisionPattern options:REG_ICASE]) {
			[[NSBundle mainBundle] loadNibNamed:@"RevisionCell" owner:self options:nil];
		} else if ([subtitle matchedByPattern:errorPattern options:REG_ICASE]) {
			[[NSBundle mainBundle] loadNibNamed:@"ErrorCell" owner:self options:nil];
		} else {
			[[NSBundle mainBundle] loadNibNamed:@"SupportCell" owner:self options:nil];
		}
	}
	
	[subtitleCell setCellDataWithTitle:title author:author];
	[subtitleCell setSubtitle:subtitle];
	
	return subtitleCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	if(self.webViewController == nil)
		self.webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	
	[self.webViewController setIssue:[_issues objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:self.webViewController animated:YES];
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

- (void)dealloc {
	[activityIndicator release];
	[_issues release];
	[issuesTable release];
	[webViewController release];
	[subtitleCell release];
    [super dealloc];
}


@end
