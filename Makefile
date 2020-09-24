ARCHS = arm64 arm64e
TARGET = iphone:clang::11.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = BundleIDsXI
BundleIDsXI_FILES = main.m BundleIDsAppDelegate.m RootViewController.m
BundleIDsXI_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"BundleIDsXI\"" || true
SUBPROJECTS += libskittyapplist
include $(THEOS_MAKE_PATH)/aggregate.mk
