//
//  AdNavigator.h
//  iRedmine
//
//  Created by Thomas Stägemann on 04.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdNavigationController.h"

@interface AdNavigator : TTNavigator
@end

@interface AdNavigatorWindow : UIWindow
@end

@interface UIViewController (UIViewControllerAdditions)

- (void)openURL:(NSString *)URL;
- (void)openURL:(NSString *)URL withQuery:(NSDictionary *)query;

@end

