include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Spot
Spot_FILES = Tweak.xm SpotitObject.xm SpotitTableViewController.m
Spot_FRAMEWORKS = Foundation UIKit
Spot_PRIVATE_FRAMEWORKS = SpotlightUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
