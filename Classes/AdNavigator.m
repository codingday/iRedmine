//
//  AdNavigator.m
//  iRedmine
//
//  Created by Thomas Stägemann on 04.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "AdNavigator.h"

@implementation AdNavigator

+ (id)navigator{
	TTBaseNavigator* navigator = [TTBaseNavigator globalNavigator];
	if (nil == navigator) {
		navigator = [[AdNavigator alloc] init];
		// setNavigator: retains.
		[super setGlobalNavigator:navigator];
		[navigator release];
	}
	// If this asserts, it's likely that you're attempting to use two different navigator
	// implementations simultaneously. Be consistent!
	TTDASSERT([navigator isKindOfClass:[AdNavigator class]]);
	return navigator;	
}

- (Class)navigationControllerClass {
	return [AdNavigationController class];
}

- (Class)windowClass {
	return [AdNavigatorWindow class];
}

@end

@implementation AdNavigatorWindow

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake	&& [[AdNavigator navigator] supportsShakeToReload]) {
		// If you're going to use a custom navigator implementation, you need to ensure that you
		// implement the reload method. If you're inheriting from TTNavigator, then you're fine.
		TTDASSERT([[AdNavigator navigator] respondsToSelector:@selector(reload)]);
		[(AdNavigator*)[AdNavigator navigator] reload];
	}
}

@end

@implementation UIViewController (UIViewControllerAdditions)

- (void)openURL:(NSString *)URL {
	[[AdNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:URL] applyAnimated:YES]];
}

@end

