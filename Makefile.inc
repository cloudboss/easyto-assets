ifndef DIR_OUT
$(error "DIR_OUT is not defined")
endif

ifndef DIRS_STG_CLEAN
$(error "DIRS_STG_CLEAN is not defined")
endif

DIR_ROOT = $(realpath $(CURDIR))

DIR_ET = .easyto
DIR_ET_SHA256 = $(shell echo -n $(DIR_ET) | sha256sum | awk '{print $$1}' | cut -c 1-40)
VAR_DIR_ET = $(DIR_OUT)/.var-dir-et-$(DIR_ET_SHA256)

CHRONY_USER = cb-chrony
OPENSSH_PRIVSEP_USER = cb-ssh
OPENSSH_PRIVSEP_DIR = /$(DIR_ET)/var/empty

ifeq ($(OS), windows)
EXE_SUFFIX = .exe
endif

PACKER_VERSION = 1.9.4
PACKER_EXE = packer$(EXE_SUFFIX)

PACKER_PLUGIN_AMZ_VERSION = 1.2.6
PACKER_PLUGIN_AMZ_NAME = packer-plugin-amazon_v$(PACKER_PLUGIN_AMZ_VERSION)_x5.0_$(OS)_$(ARCH)
PACKER_PLUGIN_AMZ_EXE = $(PACKER_PLUGIN_AMZ_NAME)$(EXE_SUFFIX)

# The Dockerfile and its args are hashed to create a unique tag. The image
# will be rebuilt if the hash changes, as the dependency file will change.
UID = $(shell id -u)
GID = $(shell id -g)
CTR_IMAGE_GO = golang:1.22.4-alpine3.20
UID_SHA256 = $(shell echo -n $(UID) | sha256sum | awk '{print $$1}')
GID_SHA256 = $(shell echo -n $(GID) | sha256sum | awk '{print $$1}')
CTR_IMAGE_GO_SHA256 = $(shell echo -n $(CTR_IMAGE_GO) | sha256sum | awk '{print $$1}')
DOCKERFILE_SHA256 = $(shell sha256sum Dockerfile.build | awk '{print $$1}')
DOCKER_INPUTS_SHA256 = $(shell echo -n $(UID_SHA256)$(GID_SHA256)$(CTR_IMAGE_GO_SHA256)$(DOCKERFILE_SHA256) \
	sha256sum | awk '{print $$1}' | cut -c 1-40)
CTR_IMAGE_LOCAL = $(PROJECT):$(DOCKER_INPUTS_SHA256)
HAS_IMAGE_LOCAL = $(DIR_OUT)/.image-local-$(DOCKER_INPUTS_SHA256)

HAS_COMMAND_AR = $(DIR_OUT)/.command-ar
HAS_COMMAND_CURL = $(DIR_OUT)/.command-curl
HAS_COMMAND_DOCKER = $(DIR_OUT)/.command-docker
HAS_COMMAND_FAKEROOT = $(DIR_OUT)/.command-fakeroot
HAS_COMMAND_UNZIP = $(DIR_OUT)/.command-unzip
HAS_COMMAND_XZCAT = $(DIR_OUT)/.command-xzcat

# Create any directory under $(DIR_OUT) as long as it ends in a `/` character.
$(DIR_OUT)/%/:
	@mkdir -p $(DIR_OUT)/$*

# Create empty file `$(DIR_OUT)/.command-abc` if command `abc` is found.
$(DIR_OUT)/.command-%:
	@[ -f $(DIR_OUT)/.command-$* ] || { \
		which $* >/dev/null 2>&1 && \
		mkdir -p $(DIR_OUT) && touch $(DIR_OUT)/.command-$* || \
		(echo "command $* is required"; exit 1); \
	}

# Remove DIRS_STG_CLEAN (those containing DIR_ET) if DIR_ET changes
# so the old DIR_ET doesn't end up in release artifacts.
$(VAR_DIR_ET):
	@[ -f "$(VAR_DIR_ET)" ] || { \
		rm -rf $(DIRS_STG_CLEAN); \
		touch $(VAR_DIR_ET); \
	}

# Container image build is done in empty $(DIR_OUT)/dockerbuild directory to speed it up.
$(HAS_IMAGE_LOCAL): $(HAS_COMMAND_DOCKER) | $(DIR_OUT)/dockerbuild/
	@docker build \
		--build-arg FROM=$(CTR_IMAGE_GO) \
		--build-arg GID=$(GID) \
		--build-arg UID=$(UID) \
		-f $(DIR_ROOT)/Dockerfile.build \
		-t $(CTR_IMAGE_LOCAL) \
		$(DIR_OUT)/dockerbuild
	@touch $(HAS_IMAGE_LOCAL)
