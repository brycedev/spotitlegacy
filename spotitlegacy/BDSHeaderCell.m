#import "Global.h"
#include "BDSHeaderCell.h"

@implementation BDSHeaderCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];

        if (self) {

            CGFloat width = [[UIScreen mainScreen] bounds].size.width;

            UILabel *tweakName = [[UILabel alloc] initWithFrame: CGRectMake(0, 10, width, 70)];
            [tweakName setNumberOfLines: 1];
            tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 42];
            [tweakName setText: @"Spotit"];
            [tweakName setBackgroundColor: [UIColor clearColor]];
            tweakName.textColor = [UIColor whiteColor];
            tweakName.textAlignment = NSTextAlignmentCenter;

            UILabel *subTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 70, width, 30)];
            [subTitle setNumberOfLines:1];
            [subTitle setFont: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20]];
            [subTitle setText: @"Reddit In Your Spotlight"];
            [subTitle setBackgroundColor: [UIColor clearColor]];
            [subTitle setTextColor: [UIColor whiteColor]];
            [subTitle setTextAlignment: NSTextAlignmentCenter];

            self.backgroundColor = SPOTIT_ORANGE;
            [self addSubview: tweakName];
            [self addSubview: subTitle];

        }

    return self;

}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {

    return 125.0f;

}

@end
