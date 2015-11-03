#import "Global.h"
#include "BDSInterfaceController.h"

UIColor *originalTint;
UIWindow *settingsView;

@implementation BDSInterfaceController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Interface" target:self] retain];
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
