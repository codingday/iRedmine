//
//  AddViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdNavigator.h"
#import "RootViewController.h"

@interface AccountViewController : TTViewController {
	UITextField * _loginField;
	UITextField * _urlField;
	UITextField * _passwordField;
	NSDictionary * _query;
}

@property(nonatomic,retain) IBOutlet UITextField * loginField;
@property(nonatomic,retain) IBOutlet UITextField * urlField;
@property(nonatomic,retain) IBOutlet UITextField * passwordField;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

@end
