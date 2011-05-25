//
//  BaseTableViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "Constants.h"
#import "NSURLProtectionSpaceAdditions.h"

@interface BaseTableViewController : TTTableViewController <ADBannerViewDelegate> {
	NSDictionary * _query;
	ADBannerView * _adView;
	BOOL _bannerIsVisible;
}

@property (nonatomic, retain, readonly) NSDictionary * query;

- (void)updateViewFramesWithOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;

@end
