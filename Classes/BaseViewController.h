//
//  BaseViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 05.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : TTViewController {
	NSDictionary * _query;
}

@property (nonatomic, retain, readonly) NSDictionary * query;

@end
