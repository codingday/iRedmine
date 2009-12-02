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
	UITextField * hostField;
	UITextField * passwordField;
	UITextField * portField;
	UISwitch * sslSwitch;
	
	UIBarStyle oldBarStyle;
	UIStatusBarStyle oldStatusBarStyle;
	UIColor * oldTintColor;
}

@property(nonatomic,retain) IBOutlet UITextField * loginField;
@property(nonatomic,retain) IBOutlet UITextField * hostField;
@property(nonatomic,retain) IBOutlet UITextField * passwordField;
@property(nonatomic,retain) IBOutlet UITextField * portField;
@property(nonatomic,retain) IBOutlet UISwitch * sslSwitch;
@property(nonatomic,copy) UIColor * oldTintColor;

+ (AddViewController *)sharedAddViewController;
- (IBAction)acceptAction:(id)sender;

@end
