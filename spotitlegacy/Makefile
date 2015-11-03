include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SpotitLegacy
SpotitLegacy_FILES = BDSRootListController.m BDSFeedController.m BDSInterfaceController.m BDSHeaderCell.m
SpotitLegacy_INSTALL_PATH = /Library/PreferenceBundles
SpotitLegacy_FRAMEWORKS = MessageUI UIKit
SpotitLegacy_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SpotitLegacy.plist$(ECHO_END)
