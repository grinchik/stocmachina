PORT := 2201

.PHONY: _
_:

count_files = $(shell ls -1 "$(1)" | wc --lines)

DEBUG_LOG_FILEPATH := debug.log
INPUT_DIR := input
WORKSPACE_DIR := workspace
OUTPUT_DIR := output
INPUT_EXT := .png
OUTPUT_EXT := .jpg

INPUT_FILE_LIST := $(wildcard $(INPUT_DIR)/*$(INPUT_EXT))
OUTPUT_FILE_LIST := $(INPUT_FILE_LIST:$(INPUT_DIR)/%$(INPUT_EXT)=$(OUTPUT_DIR)/%$(OUTPUT_EXT))

$(OUTPUT_DIR): \
	/
	mkdir --parents $(OUTPUT_DIR);

$(OUTPUT_DIR)/%$(OUTPUT_EXT): \
	$(INPUT_DIR)/%$(INPUT_EXT) \
	| $(OUTPUT_DIR) \
	/
	@echo "Attributed $(call count_files,"$(OUTPUT_DIR)") of $(call count_files,"$(INPUT_DIR)")";
	@bash \
		src/attribute.sh \
			"$<" \
			"$@" \
		>> \
			"$(DEBUG_LOG_FILEPATH)" \
			2>&1 \
		;

.PHONY: attributing
attributing: \
	$(OUTPUT_FILE_LIST) \
	/
	@echo "Attributed $(call count_files,"$(OUTPUT_DIR)") of $(call count_files,"$(INPUT_DIR)")";
	@echo "All files attributed successfully".

	@jq -s '.' $(WORKSPACE_DIR)/*.response.json > "$(WORKSPACE_DIR)/responseList.json";
	@node src/helpers/tokencalc.js "$(WORKSPACE_DIR)/responseList.json";

.PHONY: clean
clean: \
	/
	rm \
		--recursive \
		--force \
		debug.log \
		workspace \
		output \
		;

# https://docs.docker.com/reference/cli/docker/buildx/build/
.PHONY: build
build: \
	.ssh/authorized_keys \
	/
	sudo \
		docker \
			buildx \
				build \
					-t stocmachina \
					-f ./stocmachina.Dockerfile \
					. \
	;

# https://docs.docker.com/reference/cli/docker/container/run/
.PHONY: run
run: \
	/
	sudo \
		docker \
			run \
				--gpus all \
				--rm \
				--detach \
				--publish $(PORT):22 \
				--volume $(shell pwd)/config:/stocmachina/config \
				--name stocmachina \
				stocmachina \
	;

.PHONY: debug
debug: \
	/
	sudo \
		docker \
			run \
				--gpus all \
				--rm \
				--interactive \
				--tty \
				--publish $(PORT):22 \
				--volume $(shell pwd)/src:/stocmachina \
				--volume $(shell pwd)/config:/stocmachina/config \
				--name stocmachina \
				stocmachina \
				bash \
	;

SSH_KEY_DIR := .ssh
KEY_FILE_NAME := stocmachina-key

.ssh/authorized_keys: \
	/
	mkdir \
		--parents \
			"$(SSH_KEY_DIR)" \
	;
	ssh-keygen \
		-t ed25519 \
		-C "$(SSH_KEY_DIR)/$(KEY_FILE_NAME)" \
		-f "$(SSH_KEY_DIR)/$(KEY_FILE_NAME)" \
	;
	cat \
		"$(SSH_KEY_DIR)/$(KEY_FILE_NAME).pub" \
			> \
				"$(SSH_KEY_DIR)/authorized_keys" \
	;
	chmod \
		0600 \
			"$(SSH_KEY_DIR)/$(KEY_FILE_NAME)" \
	;
