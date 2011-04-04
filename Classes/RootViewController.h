//
//  RootViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountViewController.h"
#import "BadgeCell.h"
#import "ProjectTableController.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import "iRedmineAppDelegate.h"
#import "RMConnector.h"
#import "AccountCell.h"

@interface RootViewController : UITableViewController
{
	AccountCell * _accountCell;
	ProjectTableController * _projectTableController;
	ProjectViewController * _projectViewController;
	UITableView * _accountTable;
	NSMutableArray * _activeConnects;
}

@property(nonatomic,retain) IBOutlet AccountCell * accountCell;
@property(nonatomic,retain) ProjectTableController * projectTableController;
@property(nonatomic,retain) ProjectViewController * projectViewController;
@property(nonatomic,retain) IBOutlet UITableView * accountTable;
@property(retain,readonly) NSMutableArray * activeConnects;

- (IBAction)addAccount:(id)sender;
- (IBAction)refreshAccounts:(id)sender;
- (void)connectWithURLString:(NSString *)urlString username:(NSString *)username password:(NSString *)password;
- (void)updateControls;

@end
