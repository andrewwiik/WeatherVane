include $(THEOS)/makefiles/common.mk

ARCHS = arm64
TWEAK_NAME = WeatherVane
WeatherVane_FILES = WiFi.xm Bluetooth.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-all::
	@echo Signing Binary
	@ldid -S $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib
	@echo Copying to Distribution Folder
	@mkdir -p $(THEOS_PROJECT_DIR)/Distribution/SBInject
	@cp ./$(TWEAK_NAME).plist $(THEOS_PROJECT_DIR)/Distribution/SBInject
	@cp $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib $(THEOS_PROJECT_DIR)/Distribution/SBInject
	@find $(THEOS_PROJECT_DIR)/Distribution/ -name ".DS_Store" -depth -exec rm {} \;

after-install::
	install.exec "killall -9 SpringBoard"
