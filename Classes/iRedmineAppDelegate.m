//
//  iRedmineAppDelegate.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "iRedmineAppDelegate.h"

@implementation iRedmineAppDelegate

@synthesize window=_window;
@synthesize navigationController=_navigationController;

#pragma mark -
#pragma mark UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Configure and show the window
	[_window addSubview:[_navigationController view]];
	[_window makeKeyAndVisible];
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
		[_navigationController pushViewController:addViewController animated:YES];			
		return YES;
	}
	else return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[_navigationController setDelegate:nil];
	[_navigationController release]; _navigationController = nil;
	
	[_window release]; _window = nil;
	
    [super dealloc];
}

@end
