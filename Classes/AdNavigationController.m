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
	
		CGRect sbFrame = [[UIApplication sharedApplication] statusBarFrame];

		if (_bannerIsVisible) {
			[_contentView setFrame:CGRectMake(0,_adView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - _adView.frame.size.height)];
			[_adView setFrame:CGRectMake(0,sbFrame.size.height, self.view.bounds.size.width, _adView.frame.size.height)];
		}
		else {
			[_contentView setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
			[_adView setFrame:CGRectMake(0,sbFrame.size.height-_adView.frame.size.height, self.view.bounds.size.width, _adView.frame.size.height)];
		}

	}
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Notification

- (void)statusBarWillChangeFrame:(NSNotification *)notification {
	CGRect frame = [[[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
	
	[UIView beginAnimations:@"changeStatusBar" context:NULL];
	{
		[UIView setAnimationDuration:0.2];
		
		CGRect adFrame = [_adView frame];
		
		if (_bannerIsVisible) {
			adFrame.origin.y = (frame.size.height > frame.size.width)? frame.size.width : frame.size.height;
		}
		else {
			adFrame.origin.y = ((frame.size.height > frame.size.width)? frame.size.width : frame.size.height) - adFrame.size.height;
		}

		[_adView setFrame:adFrame];
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
