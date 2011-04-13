//
//  AccountAddViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AccountAddViewController : BaseViewController <UITextFieldDelegate, UIAlertViewDelegate> {
	UITextField * _loginField;
	UITextField * _urlField;
	UITextField * _passwordField;
}

@property(nonatomic,retain) IBOutlet UITextField * loginField;
@property(nonatomic,retain) IBOutlet UITextField * urlField;
@property(nonatomic,retain) IBOutlet UITextField * passwordField;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
