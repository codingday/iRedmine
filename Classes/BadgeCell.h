//
//  BadgeCell.h
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface BadgeCell : UITableViewCell 
{
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *subtitleLabel;
    IBOutlet UILabel *badgeLabel;
	IBOutlet UIImageView *badgeImage;
}

- (void)setCellDataWithTitle:(NSString*)title subTitle:(NSString *)subTitle;
- (void)setBadge:(NSUInteger)badge;

@end
