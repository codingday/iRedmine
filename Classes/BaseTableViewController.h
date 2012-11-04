//
//  BaseTableViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "NSURLProtectionSpaceAdditions.h"

@interface BaseTableViewController : TTTableViewController {
	NSDictionary * _query;
}

@property (nonatomic, retain, readonly) NSDictionary * query;

- (void)updateViewFramesWithOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;

@end
