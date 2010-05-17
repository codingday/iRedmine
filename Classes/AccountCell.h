//
//  AccountCell.h
//  iRedmine
//
//  Created by Thomas Stägemann on 12.05.10.
//  Copyright 2010 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeCell.h"

@interface AccountCell : BadgeCell 
{
	IBOutlet UIImageView *sslImage;
	
	NSURL * _url;
}

- (void)setURL:(NSURL*)url;
- (NSURL *) url;	

@end
