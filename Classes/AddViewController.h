//
//  AddViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AddViewController : UIViewController {
	UITextField * loginField;
	UITextField * urlField;
	UITextField * passwordField;
	
	UIBarStyle oldBarStyle;
	UIStatusBarStyle oldStatusBarStyle;
	UIColor * oldTintColor;
}

@property(nonatomic,retain) IBOutlet UITextField * loginField;
@property(nonatomic,retain) IBOutlet UITextField * urlField;
@property(nonatomic,retain) IBOutlet UITextField * passwordField;
@property(nonatomic,copy) UIColor * oldTintColor;

+ (AddViewController *)sharedAddViewController;
- (IBAction)acceptAction:(id)sender;

@end
