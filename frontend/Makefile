CUSTOM_COMPILE_TARGETS := ../priv/static/dev/fastclick.js \
	../priv/static/dev/fonts

CUSTOM_DIST_TARGETS := ../priv/static/prod/fastclick.js \
	../priv/static/prod/fonts

include elm.mk

$(BUILD_FOLDER)/fonts: fonts
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@mkdir -p $@
	@cp $</* $@/

$(DIST_FOLDER)/fonts: fonts
	@echo "${WHITE}[PROD]${RESET} Copying $@"
	@mkdir -p $@
	@cp $</* $@/

$(BUILD_FOLDER)/fastclick.js: src/fastclick.js
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@cp $< $@

$(DIST_FOLDER)/fastclick.js: src/fastclick.js
	@echo "${WHITE}[PROD]${RESET} Copying $@"
	@cp $< $@

