    //
//  AdTableController.m
//  NoSpam
//
//  Created by Thomas Stägemann on 22.11.10.
//  Copyright 2010 Thomas Stägemann. All rights reserved.
//

#import "AdNavigationController.h"

static const NSTimeInterval kBannerSlideInAnimationDuration = 0.5;

@implementation AdNavigationController

#pragma mark -
#pragma mark View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
	
    _contentView = [[self view] retain];
    [self setView:[[[UIView alloc] initWithFrame:[_contentView frame]] autorelease]];
	[[self view] setAutoresizingMask:[_contentView autoresizingMask]];	
    [[self view] addSubview:_contentView];
		
	CGRect sbFrame = [[UIApplication sharedApplication] statusBarFrame];
    _adView = [[[ADBannerView alloc] initWithFrame: CGRectMake(0, sbFrame.size.height-50, 320, 50)] retain];
	[_adView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
	[_adView setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifier320x50,ADBannerContentSizeIdentifier480x32,nil]];
	[_adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
	[_adView setDelegate:self];
	[[self view] addSubview:_adView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarWillChangeFrame:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self updateViewFramesWithOrientation:toInterfaceOrientation duration:duration];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)updateViewFramesWithOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{
	if (UIInterfaceOrientationIsLandscape(orientation))
		[_adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier480x32];
	else
		[_adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
	
	[UIView beginAnimations:@"showBanner" context:NULL];
	{
		[UIView setAnimationDuration:duration];
	
		CGSize sbSize = [[UIApplication sharedApplication] statusBarFrame].size;

		[_contentView setFrame:[[self view] bounds]];
		if (_bannerIsVisible) {
			if ([self isToolbarHidden])
				[_contentView setHeight:[[self view] height] - [_adView height]];
			else
				[_contentView setHeight:[[self view] height] - [_adView height] + [[self toolbar] height]];
			
			[_contentView setTop:[_adView height]];
			[_adView setTop:(sbSize.height > sbSize.width)? sbSize.width : sbSize.height];
		}
		else {
			[_adView setTop:(sbSize.height > sbSize.width)? sbSize.width : sbSize.height-[_adView height]];
		}

	}
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Notification

- (void)statusBarWillChangeFrame:(NSNotification *)notification {
	CGSize sbSize = [[[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue].size;
	
	[UIView beginAnimations:@"changeStatusBar" context:NULL];
	{
		[UIView setAnimationDuration:0.2];
				
		if (_bannerIsVisible)
			[_adView setTop:(sbSize.height > sbSize.width)? sbSize.width : sbSize.height];
		else
			[_adView setTop:(sbSize.height > sbSize.width)? sbSize.width : sbSize.height-[_adView height]];
	}
	[UIView commitAnimations];
	
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[super viewDidUnload];
	[_contentView release]; _contentView = nil;
	
	[_adView setDelegate:nil];
	[_adView release]; _adView = nil;
	
	_bannerIsVisible = NO;	
}

- (void)dealloc {
	[_contentView release]; _contentView = nil;

	[_adView setDelegate:nil];
	[_adView release]; _adView = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark AdViewBannerDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	if (!_bannerIsVisible) {
		_bannerIsVisible = YES;
		[self updateViewFramesWithOrientation:[self interfaceOrientation] duration:kBannerSlideInAnimationDuration];
	}
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	if (_bannerIsVisible) {
		_bannerIsVisible = NO;
		[self updateViewFramesWithOrientation:[self interfaceOrientation] duration:kBannerSlideInAnimationDuration];
	}
}

@end
