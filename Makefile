export DEBUG = 1
export GO_EASY_ON_ME = 1

export THEOS_DEVICE_IP=192.168.1.148
export THEOS_DEVICE_PORT=22
export TARGET = iphone:clang:latest:6.0

include theos/makefiles/common.mk

TWEAK_NAME = autotinder
autotinder_FILES = Tweak.xm
autotinder_CFLAGS = -fobjc-arc
autotinder_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Tinder"

release::
	@$(MAKE) clean DEBUG="" MAKELEVEL=0 THEOS_SCHEMA="" SCHEMA="release" GO_EASY_ON_ME=0