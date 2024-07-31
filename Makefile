PORT := 2201

.PHONY: _
_:

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
