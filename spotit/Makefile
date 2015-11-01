include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Spotit
Spotit_FILES = BDSRootListController.m BDSFeedController.m BDSInterfaceController.m BDSHeaderCell.m
Spotit_INSTALL_PATH = /Library/PreferenceBundles
Spotit_FRAMEWORKS = MessageUI UIKit
Spotit_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Spotit.plist$(ECHO_END)
