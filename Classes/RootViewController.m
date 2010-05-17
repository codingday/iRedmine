//
//  RootViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize accountCell;
@synthesize addViewController;
@synthesize projectTableController;
@synthesize projectViewController;
@synthesize accountTable;
@synthesize activeConnects;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	activeConnects = [[NSMutableArray array] retain];	
	
	// First Launch
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	BOOL launchedBefore = [defaults boolForKey:@"launchedBefore"];
	if(!launchedBefore) {
		NSArray * demoURLStrings = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DemoURLs"];
		NSMutableDictionary * accounts = [NSMutableDictionary dictionary];

		for (NSString * demoURLString in demoURLStrings) {
			NSDictionary * demoAccount = [NSDictionary dictionaryWithObjectsAndKeys:demoURLString, @"url",@"", @"username", @"", @"password", nil];
			[accounts setObject:demoAccount forKey:demoURLString];
		}
		
		[defaults setObject:accounts forKey:@"accounts"];	
		[defaults setBool:YES forKey:@"launchedBefore"];
		[defaults synchronize];		
		[self refreshProjects:self];
	}	
}

- (IBAction)addAccount:(id)sender {
	if(self.addViewController == nil)
		self.addViewController = [AddViewController sharedAddViewController];
	
	[self.navigationController pushViewController:self.addViewController animated:YES];	
}

- (IBAction)refreshProjects:(id)sender {	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSArray * accounts = [[defaults dictionaryForKey:@"accounts"] allValues];
	
	for(NSDictionary * account in accounts)	{		
		NSString * urlString = [account valueForKey:@"url"];
		NSString * password  = [account valueForKey:@"password"];
		NSString * username  = [account valueForKey:@"username"];
		RMConnector * conn = [[RMConnector connectorWithUrlString:urlString username:username password:password] retain];
		[conn setDelegate:self];
		[conn setDidStartSelector:@selector(connectBegan:)];
		[conn setDidFinishSelector:@selector(connectCompleted:)];
		[conn setDidFailSelector:@selector(connectFailed:)];
		[conn start];
	}
}

- (void)connectBegan:(RMConnector *)connector {
	NSLog(@"refreshing: %@",[connector urlString]);
	[activeConnects addObject:connector];
	[self updateControls];
	[accountTable reloadData];
}

- (void)connectFailed:(RMConnector *)connector {
	[activeConnects removeObject:connector];
	[self updateControls];

	if ([[connector error] code] != ASIRequestCancelledErrorType) {
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:[connector urlString] message:[[connector error] localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
	}
}

- (void)connectCompleted:(RMConnector *)connector {
	[activeConnects removeObject:connector];
	[self updateControls];
	
	// Cache the response dict in the user defaults
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * accounts = [[defaults dictionaryForKey:@"accounts"] mutableCopy];
	NSMutableDictionary * account  = [[accounts valueForKey:[connector urlString]] mutableCopy];
	[account setValue:[connector responseDictionary] forKey:@"data"];
	[accounts setValue:account forKey:[connector urlString]];
	[defaults setValue:accounts forKey:@"accounts"];
	[defaults synchronize];
	[accountTable reloadData];
}

- (void)updateControls {
	BOOL isActive = [[self activeConnects] count] > 0;
	[[[self navigationItem] rightBarButtonItem] setEnabled:!isActive];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isActive];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[accountTable reloadData];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults dictionaryForKey:@"accounts"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"AccountCell";
 	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary * accountDict = [[[defaults dictionaryForKey:@"accounts"] allValues] objectAtIndex:indexPath.row];

    accountCell = (AccountCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(accountCell == nil)
        [[NSBundle mainBundle] loadNibNamed:@"AccountCell" owner:self options:nil];
	[accountCell setAccessoryType:UITableViewCellAccessoryNone];
		
	NSString * username = [accountDict valueForKey:@"username"];
	if([username length] == 0) username = NSLocalizedString(@"Anonymous",@"Anonymous");
		
	NSString * subtitle = [NSString stringWithFormat:NSLocalizedString(@"Username: %@",@"Username: %@"),username];
	NSString * urlString = [accountDict valueForKey:@"url"];
	NSURL * url = [NSURL URLWithString:urlString];
	[accountCell setCellDataWithTitle:[url host] subTitle:subtitle];
	[accountCell setURL:url];
	
	NSArray * projects = [accountDict valueForKeyPath:@"data.projects.content"];
	if ((projects != nil) && ([projects count] > 0)) {
		[accountCell setBadge:[projects count]];
		[accountCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
	for (RMConnector * conn in activeConnects) {
		if ([[conn urlString] isEqualToString:urlString]) {
			UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[indicator startAnimating];
			[accountCell setAccessoryView:indicator];
			break;
		}
	}
	
	return accountCell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	AccountCell * cell = (AccountCell*)[tableView cellForRowAtIndexPath:indexPath];
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary * accounts = [[defaults valueForKey:@"accounts"] mutableCopy];
		[accounts removeObjectForKey:[[cell url] absoluteString]];
		[defaults setValue:accounts forKey:@"accounts"];
		[defaults synchronize];
		// Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary * accountDict = [[[defaults dictionaryForKey:@"accounts"] allValues] objectAtIndex:indexPath.row];
	
	NSDictionary * myPage   = [accountDict valueForKeyPath:@"data.myPage"];
	NSDictionary * projects = [accountDict valueForKeyPath:@"data.projects.content"];

	if ((projects == nil) || ([projects count] == 0))
		return;
	
	if ([projects count] == 1 && (!myPage || [myPage count] == 0)) {
		if(self.projectViewController == nil)
			self.projectViewController = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
		
		self.projectViewController.project = [[projects allValues] objectAtIndex:0];		
		[self.navigationController pushViewController:self.projectViewController animated:YES];
		return;
	}

	if(self.projectTableController == nil)
		self.projectTableController = [[ProjectTableController alloc] initWithNibName:@"ProjectTableView" bundle:nil];
		
	self.projectTableController.accountDict = accountDict;	
	[self.navigationController pushViewController:self.projectTableController animated:YES];
}

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
	[accountCell release];
	[addViewController release];
	[projectTableController release];
	[projectViewController release];
	[accountTable release];
	[activeConnects release];
    [super dealloc];
}


@end

