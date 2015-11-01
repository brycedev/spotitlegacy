#import "Global.h"
#include "BDSFeedController.h"

UIColor *originalTint;
UIWindow *settingsView;

@implementation BDSFeedController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Feed" target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {

	[super loadView];

	[UISwitch appearanceWhenContainedIn: self.class, nil].onTintColor = SPOTIT_ORANGE;
	[UISegmentedControl appearanceWhenContainedIn: self.class, nil].tintColor = SPOTIT_ORANGE;

}

- (void)viewWillAppear:(BOOL)animated {

	settingsView = [[UIApplication sharedApplication] keyWindow];
	originalTint = settingsView.tintColor;
	settingsView.tintColor = SPOTIT_ORANGE;

}

- (void)viewWillDisappear:(BOOL)animated {

	settingsView.tintColor = originalTint;

}

@end
