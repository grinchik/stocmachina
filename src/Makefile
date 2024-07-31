INPUT_DIR := input
OUTPUT_DIR := output
WORKSPACE_DIR := workspace
CONFIG_DIR := config

INPUT_EXT := .png
CLEANED_SUFFIX := cleaned
CLEANED_EXT := .$(CLEANED_SUFFIX).png

RESIZED_EXT := $(CLEANED_EXT).resized.png
BASE64_EXT := $(RESIZED_EXT).base64
REQUEST_EXT := $(BASE64_EXT).request.json
RESPONSE_EXT := $(REQUEST_EXT).response.json
METADATA_EXT := $(RESPONSE_EXT).metadata.txt
OUTPUT_EXT := .jpg

UPSCLALED_SUFFIX := upscaled
UPSCALED_EXT := .$(CLEANED_SUFFIX)_$(UPSCLALED_SUFFIX).png

.PRECIOUS: $(INPUT_DIR)/%$(INPUT_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(CLEANED_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(RESIZED_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(BASE64_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(REQUEST_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(RESPONSE_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(METADATA_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(UPSCALED_EXT)
.PRECIOUS: $(WORKSPACE_DIR)/%$(OUTPUT_EXT)
.PRECIOUS: $(OUTPUT_DIR)/%$(OUTPUT_EXT)

INPUT_FILE_LIST := $(wildcard $(INPUT_DIR)/*$(INPUT_EXT))
OUTPUT_FILE_LIST := $(INPUT_FILE_LIST:$(INPUT_DIR)/%$(INPUT_EXT)=$(OUTPUT_DIR)/%$(OUTPUT_EXT))

.PHONY: _
_: \
	$(OUTPUT_FILE_LIST) \
	/

$(OUTPUT_DIR): \
	/
	mkdir --parents $(OUTPUT_DIR);

$(WORKSPACE_DIR): \
	/
	mkdir --parents $(WORKSPACE_DIR);

.PHONY: clean
clean: \
	/
	-rm -rf $(INPUT_DIR);
	-rm -rf $(OUTPUT_DIR);
	-rm -rf $(WORKSPACE_DIR);

$(WORKSPACE_DIR)/%$(CLEANED_EXT): \
	$(INPUT_DIR)/%$(INPUT_EXT) \
	| $(CLEANED_DIR) \
	/
	exiftool \
		-all= \
		-out "$@" \
		"$<" \
	;

$(WORKSPACE_DIR)/%$(RESIZED_EXT): \
	$(WORKSPACE_DIR)/%$(CLEANED_EXT) \
	| $(WORKSPACE_DIR) \
	/
	convert \
		"$<" \
		-resize x512 \
		"$@" \
	;


$(WORKSPACE_DIR)/%$(BASE64_EXT): \
	$(WORKSPACE_DIR)/%$(RESIZED_EXT) \
	| $(WORKSPACE_DIR) \
	/
	base64 \
		--wrap=0 \
		"$<" \
			> \
				"$@" \
	;

$(WORKSPACE_DIR)/%$(REQUEST_EXT): \
	$(WORKSPACE_DIR)/%$(BASE64_EXT) \
	| $(WORKSPACE_DIR) \
	/
	node \
		helpers/request.js \
			"$(CONFIG_DIR)/SYSTEM_PROMPT.md" \
			"$(CONFIG_DIR)/USER_PROMPT.md" \
			"$<" \
				> \
					"$@" \
	;

$(WORKSPACE_DIR)/%$(RESPONSE_EXT): \
	$(WORKSPACE_DIR)/%$(REQUEST_EXT) \
	| $(WORKSPACE_DIR) \
	/
	curl \
		--request POST \
		--header "Content-Type: application/json" \
		--header "Authorization: $(shell cat $(CONFIG_DIR)/OPENAI_API_KEY)" \
		--data @"$<"\
		--output "$@" \
		--progress-bar \
		https://api.openai.com/v1/chat/completions

# TODO: Validate response
$(WORKSPACE_DIR)/%$(METADATA_EXT): \
	$(WORKSPACE_DIR)/%$(RESPONSE_EXT) \
	| $(WORKSPACE_DIR) \
	/
	node \
		helpers/metadata.js \
			"$<" \
				> \
					"$@" \
	;

$(WORKSPACE_DIR)/%$(UPSCALED_EXT): \
	$(WORKSPACE_DIR)/%$(CLEANED_EXT) \
	| $(WORKSPACE_DIR) \
	/
	cd /RealESRGAN \
	&& \
	./venv/bin/python \
		inference_realesrgan.py \
			--model_name RealESRGAN_x4plus \
			--input "/stocmachina/$<" \
			--suffix "$(UPSCLALED_SUFFIX)" \
			--output "/stocmachina/$(WORKSPACE_DIR)" \
	;

$(WORKSPACE_DIR)/%$(OUTPUT_EXT): \
	$(WORKSPACE_DIR)/%$(UPSCALED_EXT) \
	/
	convert \
		"$<" \
		"$@" \
	;

$(OUTPUT_DIR)/%$(OUTPUT_EXT): \
	$(WORKSPACE_DIR)/%$(OUTPUT_EXT) \
	$(WORKSPACE_DIR)/%$(METADATA_EXT) \
	| $(OUTPUT_DIR) \
	/
	exiftool \
		$(shell cat '$(WORKSPACE_DIR)/$*$(METADATA_EXT)') \
		-out "$@" \
		"$<" \
	;
