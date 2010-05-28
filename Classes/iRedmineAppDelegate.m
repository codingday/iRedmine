//
//  iRedmineAppDelegate.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "iRedmineAppDelegate.h"

@implementation iRedmineAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if ([[url host] isEqualToString:@"account"]) {
		AccountViewController * addViewController = [AccountViewController sharedAccountViewController];
		NSArray * parameters = [[url query] componentsSeparatedByString:@"&"];
		for (NSString * parameter in parameters) {
			NSArray * keyValue = [parameter componentsSeparatedByString:@"="];
			if ([[keyValue objectAtIndex:0] isEqualToString:@"url"])
				[[addViewController urlField] setText:[keyValue lastObject]];
			else if ([[keyValue objectAtIndex:0] isEqualToString:@"login"])
				[[addViewController loginField] setText:[keyValue lastObject]];
			else if ([[keyValue objectAtIndex:0] isEqualToString:@"password"])
				[[addViewController passwordField] setText:[keyValue lastObject]];
		}
		[navigationController pushViewController:addViewController animated:YES];			
		return YES;
	}
	else return NO;
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
