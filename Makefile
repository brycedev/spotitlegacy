include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Spotit
Spotit_FILES = Tweak.xm SpotitObject.m SpotitTableViewController.m SpotitWebViewController.m BDSettingsManager.m
Spotit_FRAMEWORKS = CoreFoundation Foundation UIKit SafariServices
Spotit_PRIVATE_FRAMEWORKS = Search SpotlightUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences; killall -9 SpringBoard"
SUBPROJECTS += spotit
include $(THEOS_MAKE_PATH)/aggregate.mk
