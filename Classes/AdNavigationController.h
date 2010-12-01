//
//  AdTableController.h
//  NoSpam
//
//  Created by Thomas Stägemann on 22.11.10.
//  Copyright 2010 Thomas Stägemann. All rights reserved.
//

#import <iAd/iAd.h>

@interface AdNavigationController : UINavigationController <ADBannerViewDelegate> {
	ADBannerView * _adView;
	UIView * _contentView;
	BOOL _bannerIsVisible;
}

- (void)updateViewFramesWithOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;

@end
