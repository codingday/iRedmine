//
//  RootViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "RootViewController.h"
#import "iRedmineAppDelegate.h"

@implementation RootViewController

@synthesize badgeCell;
@synthesize addViewController;
@synthesize projectTableController;
@synthesize projectViewController;
@synthesize accountTable;
@synthesize networkQueue;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"iRedmine"];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
	networkQueue = [[ASINetworkQueue queue] retain];	
	[self refreshProjects:self];
}

- (IBAction)openPreferences:(id)sender
{
	if(self.addViewController == nil)
		self.addViewController = [AddViewController sharedAddViewController];
	
	[self.navigationController pushViewController:self.addViewController animated:YES];
	
	// Set up the text view...
	
}

- (IBAction)refreshProjects:(id)sender
{	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	// First Launch
	BOOL launchedBefore = [defaults boolForKey:@"launchedBefore"];
	if(!launchedBefore) {
		NSString * demoHostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DemoHostName"];
		NSString * redmineHostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RedmineHostName"];
		NSDictionary * demoAccount = [NSDictionary dictionaryWithObjectsAndKeys:demoHostName, @"hostname",@"", @"username", @"", @"password", nil];
		NSDictionary * redmineAccount = [NSDictionary dictionaryWithObjectsAndKeys:redmineHostName, @"hostname",@"", @"username", @"", @"password", nil];
		NSDictionary * accounts = [NSDictionary dictionaryWithObjectsAndKeys:demoAccount,demoHostName,redmineAccount,redmineHostName,nil];
		[defaults setObject:accounts forKey:@"accounts"];	
		[defaults setBool:YES forKey:@"launchedBefore"];
		[defaults synchronize];		
	}
	
    NSArray * accounts = [[defaults dictionaryForKey:@"accounts"] allValues];
	[networkQueue cancelAllOperations];
	[networkQueue setRequestDidStartSelector:@selector(fetchBegins:)];
	[networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
	[networkQueue setQueueDidFinishSelector:@selector(queueDidFinish:)];
	[networkQueue setShowAccurateProgress:YES];
	[networkQueue setShouldCancelAllRequestsOnFailure:NO];
	[networkQueue setDelegate:self];

	for(NSDictionary * account in accounts)
	{								
		ASIFormDataRequest * projectsRequest = [[self requestWithAccount:account URLPath:@"projects?format=atom"] retain];
		[projectsRequest setUserInfo:[NSDictionary dictionaryWithObject:@"projects" forKey:@"feed"]];
		[networkQueue addOperation:projectsRequest];
		
		NSString * password = [account valueForKey:@"password"];
		NSString * username = [account valueForKey:@"username"];
		if([password length] > 0 && [username length] > 0){
			ASIFormDataRequest * assignedRequest = [[self requestWithAccount:account URLPath:@"issues?format=atom&assigned_to_id=me"] retain];
			[assignedRequest setUserInfo:[NSDictionary dictionaryWithObject:@"assigned" forKey:@"feed"]];
			[networkQueue addOperation:assignedRequest];
			
			ASIFormDataRequest * reportedRequest = [[self requestWithAccount:account URLPath:@"issues?format=atom&author_id=me"] retain];
			[reportedRequest setUserInfo:[NSDictionary dictionaryWithObject:@"reported" forKey:@"feed"]];
			[networkQueue addOperation:reportedRequest];
		}
	}
	[networkQueue go];
	[accountTable reloadData];
}

- (ASIFormDataRequest *)requestWithAccount:(NSDictionary *)account URLPath:(NSString *)path{
	BOOL useSSL			= [[account valueForKey:@"ssl"] boolValue];
	NSString * password = [account valueForKey:@"password"];
	NSString * username = [account valueForKey:@"username"];
	NSString * hostname = [account valueForKey:@"hostname"];
	NSString * protocol = useSSL? @"https" : @"http";
	int port			= [[account valueForKey:@"port"] intValue];
	if(!port && useSSL){
		port = 443;
	} else if (!port){
		port = 80;
	}

	NSURL * loginURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%d/login",protocol,hostname,port]];
	NSURL * feedURL  = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%d/%@",protocol,hostname,port,path]];
	
	ASIFormDataRequest * request;
	if(([password length] > 0) && ([username length] > 0)){
		request = [ASIFormDataRequest requestWithURL:loginURL];
		[request setPostValue:username forKey:@"username"];
		[request setPostValue:password forKey:@"password"];
		[request setPostValue:[feedURL absoluteString] forKey:@"back_url"];
	} else {
		request = [ASIFormDataRequest requestWithURL:feedURL];
	}
	
	[request setTimeOutSeconds:200];
	[request setUseKeychainPersistance:YES];
	[request setShouldPresentAuthenticationDialog:YES];
	return request;
}

- (void)fetchBegins:(id)request{
}

- (void)fetchFailed:(id)request{
	if ([[request error] code] != ASIRequestCancelledErrorType) {
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:[[request url] host] message:[[request error] localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
	}
}

- (void)fetchComplete:(id)request{
	NSString * host = [[request url] host];
	//NSLog(@"Fetch from %@ completed: %@",host,[request responseString]);
	
	// Load and parse the xml response
	TBXML * xml = [[TBXML alloc] initWithXMLString:[request responseString]];
	
	if (![[request responseString] hasPrefix:@"<?xml"]) {
		//NSLog(@"Fetch from %@ with invalid xml: %@",host,[request responseString]);
		NSString * errorString = NSLocalizedString(@"Invalid XML, password or user name are probably incorrect.",@"Invalid XML, password or user name are probably incorrect.");
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:host message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
	}
	// if root element is valid
	else if ([xml rootXMLElement]) {
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary * accounts = [[defaults dictionaryForKey:@"accounts"] mutableCopy];
		NSMutableDictionary * account = [[accounts valueForKey:host] mutableCopy];

		NSString * feedInfo = [[request userInfo] valueForKey:@"feed"];
		if ([feedInfo isEqualToString:@"projects"]) {
			NSArray * projects = [self arrayOfDictionariesWithXML:xml forKeyPaths:[NSArray arrayWithObjects:@"title",@"content",@"id",@"updated",nil]];
			[account setValue:projects forKey:@"projects"];

			for (id project in projects) {
				int projectId = [[[project valueForKey:@"id"] lastPathComponent] intValue];
				
				NSString * issuesPath = [NSString  stringWithFormat:@"projects/%d/issues?format=atom",projectId];
				ASIFormDataRequest * issuesRequest = [[self requestWithAccount:account URLPath:issuesPath] retain];
				[issuesRequest setUserInfo:[NSDictionary dictionaryWithObject:@"issues" forKey:@"feed"]];
				[networkQueue addOperation:issuesRequest];
				
				NSString * activityPath = [NSString  stringWithFormat:@"projects/%d/activity?format=atom",projectId];
				ASIFormDataRequest * activityRequest = [[self requestWithAccount:account URLPath:activityPath] retain];
				[activityRequest setUserInfo:[NSDictionary dictionaryWithObject:@"activity" forKey:@"feed"]];
				[networkQueue addOperation:activityRequest];
			}
		} else if ([feedInfo isEqualToString:@"assigned"]) {
			NSArray * assignedIssues = [self arrayOfDictionariesWithXML:xml forKeyPaths:[NSArray arrayWithObjects:@"title",@"content",@"id",@"updated",@"author.name",nil]];
			[account setValue:assignedIssues forKey:@"assigned"];
		} else if ([feedInfo isEqualToString:@"reported"]) {
			NSArray * reportedIssues = [self arrayOfDictionariesWithXML:xml forKeyPaths:[NSArray arrayWithObjects:@"title",@"content",@"id",@"updated",@"author.name",nil]];
			[account setValue:reportedIssues forKey:@"reported"];
		} else if ([feedInfo isEqualToString:@"issues"]) {
			NSArray * projectIssues = [self arrayOfDictionariesWithXML:xml forKeyPaths:[NSArray arrayWithObjects:@"title",@"content",@"id",@"updated",@"author.name",nil]];
			//[account setValue:reportedIssues forKey:@"reported"];
		} else if ([feedInfo isEqualToString:@"activity"]) {
			NSArray * projectActivities = [self arrayOfDictionariesWithXML:xml forKeyPaths:[NSArray arrayWithObjects:@"title",@"content",@"id",@"updated",@"author.name",nil]];
			//[account setValue:reportedIssues forKey:@"reported"];
		}
		
		[accounts setValue:account forKey:host];
		[defaults setObject:accounts forKey:@"accounts"];
		[defaults synchronize];
		[accountTable reloadData];		
	}
}

- (void)queueDidFinish:(ASINetworkQueue *)queue{
	[accountTable reloadData];		
}

- (NSArray *)arrayOfDictionariesWithXML:(TBXML *)xml forKeyPaths:(NSArray *)keyPaths{
	// Obtain root element
	TBXMLElement * root = [xml rootXMLElement];
	
	// instantiate an array to hold child dictionaries
	NSMutableArray * array = [NSMutableArray array];
	
	// search for the first child element within the root element's children
	TBXMLElement * entry = [xml childElementNamed:@"entry" parentElement:root];
	
	// if an child element was found
	while (entry != nil) {	
		NSMutableDictionary * dict = [NSMutableDictionary dictionary];
		
		for (NSString * keyPath in keyPaths) {
			NSArray * components = [keyPath componentsSeparatedByString:@"."];	
			TBXMLElement * parent = entry;
			TBXMLElement * element;
			for (NSString * component in components) {
				element = [xml childElementNamed:component parentElement:parent];
				parent = element;
			}
			[dict setValue:[[xml textForElement:element] stringByUnescapingHTML] forKey:keyPath];
		}		
		
		[array addObject:dict];
		
		// find the next sibling element named "entry"
		entry = [xml nextSiblingNamed:@"entry" searchFromElement:entry];
	}
	
	return array;
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults dictionaryForKey:@"accounts"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"AccountCell";
 	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary * accountDict = [[[defaults dictionaryForKey:@"accounts"] allValues] objectAtIndex:indexPath.row];

    badgeCell = (BadgeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(badgeCell == nil)
        [[NSBundle mainBundle] loadNibNamed:@"BadgeCell" owner:self options:nil];
		
	NSString * username = [accountDict valueForKey:@"username"];
	if([username length] == 0) username = NSLocalizedString(@"Anonymous",@"Anonymous");
		
	NSString * subtitle = [NSString stringWithFormat:NSLocalizedString(@"Username: %@",@"Username: %@"),username];
	[badgeCell setCellDataWithTitle:[accountDict valueForKey:@"hostname"] subTitle:subtitle];
	[badgeCell setBadge:[[accountDict valueForKey:@"projects"] count]];
	if([[accountDict valueForKey:@"projects"] count] == 0){
		[badgeCell setAccessoryType:UITableViewCellAccessoryNone];
	} else {
		[badgeCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	if ([networkQueue isNetworkActive]) {
		NSString * hostname = [accountDict valueForKey:@"hostname"];
		for (id request in [networkQueue operations]) {
			if([[[request url] host] isEqualToString:hostname]){
				UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				[activityIndicator startAnimating];
				[badgeCell setAccessoryView:activityIndicator];
			}			
		}
	}  
	return badgeCell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete){
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary * accounts = [[defaults valueForKey:@"accounts"] mutableCopy];
		NSString * key = [[accounts allKeys] objectAtIndex:indexPath.row];
		[accounts removeObjectForKey:key];
		[defaults setValue:accounts forKey:@"accounts"];
		[defaults synchronize];
		// Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary * accountDict = [[[defaults dictionaryForKey:@"accounts"] allValues] objectAtIndex:indexPath.row];
	
	if ([networkQueue isNetworkActive]) {
		NSString * hostname = [accountDict valueForKey:@"hostname"];
		for (id request in [networkQueue operations]) {
			if([[[request url] host] isEqualToString:hostname]) return NO;
		}
	}  
	
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary * accountDict = [[[defaults dictionaryForKey:@"accounts"] allValues] objectAtIndex:indexPath.row];
	
	if ([networkQueue isNetworkActive]) {
		NSString * hostname = [accountDict valueForKey:@"hostname"];
		for (id request in [networkQueue operations]) {
			if([[[request url] host] isEqualToString:hostname]) return;
		}
	}  

	NSString * password = [accountDict valueForKey:@"password"];
	NSString * username = [accountDict valueForKey:@"username"];
	NSArray  * projects = [accountDict valueForKey:@"projects"];

	if ([projects count] == 1 && ([username length] == 0 || [password length] == 0)) {
		if(self.projectViewController == nil)
			self.projectViewController = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
		
		self.projectViewController.project = [projects objectAtIndex:0];		
		[self.navigationController pushViewController:self.projectViewController animated:YES];
	}
	else if ([projects count] > 0){
		if(self.projectTableController == nil)
			self.projectTableController = [[ProjectTableController alloc] initWithNibName:@"ProjectTableView" bundle:nil];
		
		self.projectTableController.accountDict = accountDict;	
		[self.navigationController pushViewController:self.projectTableController animated:YES];
	}

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
	[badgeCell release];
	[addViewController release];
	[projectTableController release];
	[projectViewController release];
	[accountTable release];
	[networkQueue release];
    [super dealloc];
}


@end

