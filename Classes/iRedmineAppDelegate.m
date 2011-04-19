//
//  iRedmineAppDelegate.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "iRedmineAppDelegate.h"


@implementation iRedmineAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication*)application {		
	[TTDefaultStyleSheet setGlobalStyleSheet:[[iRedmineStyleSheet alloc] init]];
	
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
	}
	
	// Each Launch
	[[TTNavigator navigator] setPersistenceMode:TTNavigatorPersistenceModeAll];
	[[TTNavigator navigator] setSupportsShakeToReload:YES];
	
	TTURLMap* map = [[TTNavigator navigator] URLMap];
	[map from:@"*" toViewController:[TTWebController class]];
	[map from:@"iredmine://store" toModalViewController:[StoreViewController class]];
	[map from:@"iredmine://accounts" toSharedViewController:[AccountsViewController class]];
	[map from:@"iredmine://account"		 parent:@"iredmine://accounts" toViewController:[AccountViewController class]		   selector:nil transition:0];
	[map from:@"iredmine://account/add"  parent:@"iredmine://accounts" toModalViewController:[AccountAddViewController class]  selector:nil transition:0];
	[map from:@"iredmine://account/edit" parent:@"iredmine://accounts" toModalViewController:[AccountEditViewController class] selector:nil transition:0];
	[map from:@"iredmine://project" toViewController:[ProjectViewController class]];
	//[map from:@"iredmine://project/add" toViewController:[ProjectAddViewController class]];
	[map from:@"iredmine://mypage" toViewController:[MyPageTableController class]];
	[map from:@"iredmine://activities" toViewController:[ActivityTableController class]];
	[map from:@"iredmine://issues" toViewController:[IssueTableController class]];
	[map from:@"iredmine://issue/add" toModalViewController:[IssueAddViewController class]];
	
	if (![[TTNavigator navigator] restoreViewControllers])
		TTOpenURL(@"iredmine://accounts");
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
	TTOpenURL([URL absoluteString]);
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [super dealloc];
}

@end
