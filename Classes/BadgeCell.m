#import "BadgeCell.h"

@implementation BadgeCell

- (void)setCellDataWithTitle:(NSString*)title subTitle:(NSString *)subTitle
{
	[titleLabel setText:title];
	[subtitleLabel setText:subTitle];
}

- (void)setBadge:(NSUInteger)badge
{
	[badgeLabel setText:[NSString stringWithFormat:@"%d",badge]];
	[badgeLabel setHidden:badge == 0];
	[badgeImage setHidden:badge == 0];
}

- (void)dealloc {
	[subtitleLabel release];
	[titleLabel release];
    [super dealloc];
}

@end
