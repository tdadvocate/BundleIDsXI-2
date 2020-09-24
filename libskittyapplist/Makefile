INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
TARGET = iphone:clang::11.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = libskittyapplist

libskittyapplist_FILES = Tweak.x
libskittyapplist_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
