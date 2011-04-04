//
//  AdNavigatorWindow.m
//  iRedmine
//
//  Created by Thomas Stägemann on 04.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "AdNavigatorWindow.h"


@implementation AdNavigatorWindow


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake	&& [[AdNavigator navigator] supportsShakeToReload]) {
		// If you're going to use a custom navigator implementation, you need to ensure that you
		// implement the reload method. If you're inheriting from TTNavigator, then you're fine.
		TTDASSERT([[AdNavigator navigator] respondsToSelector:@selector(reload)]);
		[(AdNavigator*)[AdNavigator navigator] reload];
	}
}

@end
