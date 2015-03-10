export TARGET=iphone:clang:latest:6.0
export THEOS_DEVICE_PORT=22
export GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

THEOS_BUILD_DIR = Packages

TWEAK_NAME = autotinder
autotinder_FILES = Tweak.xm
autotinder_CFLAGS = -fobjc-arc
autotinder_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Tinder"

release::
	@$(MAKE) clean DEBUG="" MAKELEVEL=0 THEOS_SCHEMA="" SCHEMA="release" GO_EASY_ON_ME=1
	@$(MAKE) DEBUG="" MAKELEVEL=0 THEOS_SCHEMA="" SCHEMA="release" GO_EASY_ON_ME=1