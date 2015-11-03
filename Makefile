include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotitLegacy
SpotitLegacy_FILES = Tweak.xm SpotitObject.m SpotitTableViewController.m SpotitWebViewController.m BDSettingsManager.m
SpotitLegacy_FRAMEWORKS = CoreFoundation Foundation UIKit SafariServices
SpotitLegacy_PRIVATE_FRAMEWORKS = Search SpotlightUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences; killall -9 SpringBoard"
SUBPROJECTS += spotitlegacy
include $(THEOS_MAKE_PATH)/aggregate.mk
