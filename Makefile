PROJECT := easyto-assets
OS := $(shell uname | tr [:upper:] [:lower:])
ARCH := $(shell arch=$$(uname -m); [ "$${arch}" = "x86_64" ] && echo "amd64" || echo $${arch})
VERSION :=

DIR_ET := .easyto
DIR_OUT := _output
DIR_ROOT := $(shell echo ${PWD})

DIR_STG_BOOTLOADER := $(DIR_OUT)/staging/bootloader
DIR_STG_BASE := $(DIR_OUT)/staging/base
DIR_STG_CHRONY := $(DIR_OUT)/staging/chrony
DIR_STG_KERNEL := $(DIR_OUT)/staging/kernel
DIR_STG_SSH := $(DIR_OUT)/staging/ssh

DIR_RELEASE := $(DIR_OUT)/release
DIR_RELEASE_PACKER := $(DIR_RELEASE)/packer/$(OS)/$(ARCH)
DIR_RELEASE_PACKER_PLUGIN := $(DIR_RELEASE_PACKER)/plugins/github.com/hashicorp/amazon
DIR_RELEASE_RUNTIME := $(DIR_RELEASE)/runtime

DIR_TMPINSTALL_BTRFS_PROGS := btrfs-progs-tmpinstall
DIR_TMPINSTALL_CHRONY := chrony-tmpinstall
DIR_TMPINSTALL_E2FSPROGS := e2fsprogs-tmpinstall
DIR_TMPINSTALL_OPENSSH := openssh-tmpinstall
DIR_TMPINSTALL_OPENSSL := openssl-tmpinstall
DIR_TMPINSTALL_SUDO := sudo-tmpinstall
DIR_TMPINSTALL_UTIL_LINUX := util-linux-tmpinstall
DIR_TMPINSTALL_ZLIB := zlib-tmpinstall

# This is used to clean up staging directories containing a $(DIR_ET)
# subdirectory if that variable value changes. Since $(DIR_STG_BOOTLOADER)
# does not have a $(DIR_ET) subdirectory, it is omitted here.
DIRS_STG := $(DIR_STG_BASE) $(DIR_STG_CHRONY) $(DIR_STG_KERNEL) $(DIR_STG_SSH)

DOCKERFILE_SHA256 := $(shell sha256sum Dockerfile.build | awk '{print $$1}' | cut -c 1-40)
CTR_IMAGE_GO := golang:1.22.4-alpine3.20
CTR_IMAGE_LOCAL := $(PROJECT):$(DOCKERFILE_SHA256)

KERNEL_ORG := https://cdn.kernel.org/pub/linux

BTRFS_PROGS_VERSION := 6.5.2
BTRFS_PROGS_SRC := btrfs-progs-v$(BTRFS_PROGS_VERSION)
BTRFS_PROGS_ARCHIVE := $(BTRFS_PROGS_SRC).tar.xz
BTRFS_PROGS_URL := $(KERNEL_ORG)/kernel/people/kdave/btrfs-progs/$(BTRFS_PROGS_ARCHIVE)

E2FSPROGS_VERSION := 1.47.0
E2FSPROGS_SRC := e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_ARCHIVE := $(E2FSPROGS_SRC).tar.gz
E2FSPROGS_URL := $(KERNEL_ORG)/kernel/people/tytso/e2fsprogs/v$(E2FSPROGS_VERSION)/$(E2FSPROGS_ARCHIVE)

KERNEL_VERSION := 6.6.29
KERNEL_VERSION_MAJ := $(shell echo $(KERNEL_VERSION) | cut -c 1)
KERNEL_SRC := linux-$(KERNEL_VERSION)
KERNEL_ARCHIVE := $(KERNEL_SRC).tar.xz
KERNEL_URL := $(KERNEL_ORG)/kernel/v$(KERNEL_VERSION_MAJ).x/$(KERNEL_ARCHIVE)

EXE_SUFFIX :=
ifeq ($(OS), windows)
	EXE_SUFFIX := .exe
endif

PACKER_VERSION := 1.9.4
PACKER_ARCHIVE := packer_$(PACKER_VERSION)_$(OS)_$(ARCH).zip
PACKER_URL := https://releases.hashicorp.com/packer/$(PACKER_VERSION)/$(PACKER_ARCHIVE)
PACKER_EXE := packer$(EXE_SUFFIX)

PACKER_PLUGIN_AMZ_VERSION := 1.2.6
PACKER_PLUGIN_AMZ_NAME := packer-plugin-amazon_v$(PACKER_PLUGIN_AMZ_VERSION)_x5.0_$(OS)_$(ARCH)
PACKER_PLUGIN_AMZ_ARCHIVE := $(PACKER_PLUGIN_AMZ_NAME).zip
PACKER_PLUGIN_AMZ_URL := https://github.com/hashicorp/packer-plugin-amazon/releases/download/v$(PACKER_PLUGIN_AMZ_VERSION)/$(PACKER_PLUGIN_AMZ_ARCHIVE)
PACKER_PLUGIN_AMZ_EXE := $(PACKER_PLUGIN_AMZ_NAME)$(EXE_SUFFIX)

SYSTEMD_BOOT_VERSION := 252.12-1~deb12u1
SYSTEMD_BOOT_ARCHIVE := systemd-boot-efi_$(SYSTEMD_BOOT_VERSION)_amd64.deb
SYSTEMD_BOOT_URL := https://snapshot.debian.org/archive/debian/20230712T091300Z/pool/main/s/systemd/$(SYSTEMD_BOOT_ARCHIVE)

UTIL_LINUX_VERSION := 2.39
UTIL_LINUX_SRC := util-linux-$(UTIL_LINUX_VERSION)
UTIL_LINUX_ARCHIVE := $(UTIL_LINUX_SRC).tar.gz
UTIL_LINUX_URL := $(KERNEL_ORG)/utils/util-linux/v$(UTIL_LINUX_VERSION)/$(UTIL_LINUX_ARCHIVE)

CHRONY_VERSION := 4.5
CHRONY_SRC := chrony-$(CHRONY_VERSION)
CHRONY_ARCHIVE := $(CHRONY_SRC).tar.gz
CHRONY_URL := https://chrony-project.org/releases/$(CHRONY_ARCHIVE)
CHRONY_USER := cb-chrony

BUSYBOX_VERSION := 1.35.0
BUSYBOX_URL := https://www.busybox.net/downloads/binaries/$(BUSYBOX_VERSION)-x86_64-linux-musl/busybox
BUSYBOX_BIN := busybox-$(BUSYBOX_VERSION)

ZLIB_VERSION := 1.3.1
ZLIB_SRC := zlib-$(ZLIB_VERSION)
ZLIB_ARCHIVE := $(ZLIB_SRC).tar.gz
ZLIB_URL := https://zlib.net/$(ZLIB_ARCHIVE)

OPENSSL_VERSION := 3.2.1
OPENSSL_SRC := openssl-$(OPENSSL_VERSION)
OPENSSL_ARCHIVE := $(OPENSSL_SRC).tar.gz
OPENSSL_URL := https://www.openssl.org/source/$(OPENSSL_ARCHIVE)

OPENSSH_VERSION := V_9_7_P1
OPENSSH_SRC := openssh-portable-$(OPENSSH_VERSION)
OPENSSH_ARCHIVE := $(OPENSSH_VERSION).tar.gz
OPENSSH_URL := https://github.com/openssh/openssh-portable/archive/refs/tags/$(OPENSSH_ARCHIVE)
OPENSSH_PRIVSEP_USER := cb-ssh
OPENSSH_PRIVSEP_DIR := /$(DIR_ET)/var/empty
OPENSSH_DEFAULT_PATH := /$(DIR_ET)/bin:/$(DIR_ET)/sbin:/bin:/usr/bin:/usr/local/bin

SUDO_VERSION := 1.9.15p5
SUDO_SRC := sudo-$(SUDO_VERSION)
SUDO_ARCHIVE := $(SUDO_SRC).tar.gz
SUDO_URL := https://www.sudo.ws/dist/$(SUDO_ARCHIVE)

VAR_DIR_ET := $(DIR_OUT)/.var-dir-et
VAR_CTR_IMAGE_GO := $(DIR_OUT)/.var-ctr-image-go

HAS_COMMAND_AR := $(DIR_OUT)/.command-ar
HAS_COMMAND_CURL := $(DIR_OUT)/.command-curl
HAS_COMMAND_DOCKER := $(DIR_OUT)/.command-docker
HAS_COMMAND_FAKEROOT := $(DIR_OUT)/.command-fakeroot
HAS_COMMAND_UNZIP := $(DIR_OUT)/.command-unzip
HAS_COMMAND_XZCAT := $(DIR_OUT)/.command-xzcat
HAS_IMAGE_LOCAL := $(DIR_OUT)/.image-local-$(DOCKERFILE_SHA256)

BTRFS_PROGS_BUILD_DEPS = $(HAS_IMAGE_LOCAL) \
	$(DIR_OUT)/$(BTRFS_PROGS_SRC) \
	$(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/lib/libblkid.a \
	hack/compile-btrfsprogs-ctr

CHRONY_BUILD_OUT = $(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/bin/chronyc \
	$(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/sbin/chronyd

CHRONY_BUILD_DEPS = $(HAS_IMAGE_LOCAL) \
	$(VAR_DIR_ET) \
	$(DIR_OUT)/$(CHRONY_SRC) \
	hack/compile-chrony-ctr

E2FSPROGS_BUILD_OUT = $(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/mke2fs \
	$(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/resize2fs

E2FSPROGS_BUILD_DEPS = $(HAS_IMAGE_LOCAL) \
	$(DIR_OUT)/$(E2FSPROGS_SRC) \
	hack/compile-e2fsprogs-ctr

KERNEL_BUILD_DEPS = $(HAS_IMAGE_LOCAL) \
	$(DIR_OUT)/$(KERNEL_SRC) \
	$(VAR_DIR_ET) \
	kernel/config \
	hack/compile-kernel-ctr

OPENSSH_BUILD_OUT = $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/bin/ssh-keygen \
	$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/sbin/sshd \
	$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/libexec/sftp-server

OPENSSH_BUILD_DEPS = $(DIR_OUT)/$(OPENSSH_SRC) \
	$(VAR_DIR_ET) \
	$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL)/lib/libcrypto.a \
	$(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB)/lib/libz.a \
	hack/compile-openssh-ctr

OPENSSL_BUILD_DEPS = $(DIR_OUT)/$(OPENSSL_SRC) \
	$(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB)/lib/libz.a \
	hack/compile-openssl-ctr

SUDO_BUILD_DEPS = $(DIR_OUT)/$(SUDO_SRC) \
	$(VAR_DIR_ET) \
	hack/compile-sudo-ctr

UTIL_LINUX_BUILD_OUT = $(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/sbin/blkid.static \
	$(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/lib/libblkid.a

UTIL_LINUX_BUILD_DEPS = $(HAS_IMAGE_LOCAL) \
	$(VAR_DIR_ET) \
	$(DIR_OUT)/$(UTIL_LINUX_SRC) \
	hack/compile-util-linux-ctr

ZLIB_BUILD_DEPS = $(HAS_IMAGE_LOCAL) \
	$(DIR_OUT)/$(ZLIB_SRC) \
	hack/compile-zlib-ctr

.DEFAULT_GOAL := release

FORCE:

# Create a file to depend on the contents of $(DIR_ET). Remove the staging
# directory if it changes so the old $(DIR_ET) doesn't end up in release tarballs.
$(VAR_DIR_ET): FORCE
	@grep -qE "^$(DIR_ET)$$" $(VAR_DIR_ET) 2>/dev/null || { \
		echo $(DIR_ET) > $(VAR_DIR_ET); \
		rm -rf $(DIRS_STG); \
	}

$(VAR_CTR_IMAGE_GO): FORCE
	@grep -qE "^$(CTR_IMAGE_GO)$$" $(VAR_CTR_IMAGE_GO) 2>/dev/null || \
		echo $(CTR_IMAGE_GO) > $(VAR_CTR_IMAGE_GO)

# Create any directory under $(DIR_OUT) as long as it ends in a `/` character.
$(DIR_OUT)/%/:
	@[ -d $(DIR_OUT)/$* ] || mkdir -p $(DIR_OUT)/$*

# Create empty file `$(DIR_OUT)/.command-abc` if command `abc` is found.
$(DIR_OUT)/.command-%:
	@[ -d $(DIR_OUT) ] || mkdir -p $(DIR_OUT)
	@which $* 2>&1 >/dev/null && touch $(DIR_OUT)/.command-$* || (echo "$* is required"; exit 1)

# Container image build is done in empty $(DIR_OUT)/dockerbuild directory to speed it up.
$(DIR_OUT)/.image-local-$(DOCKERFILE_SHA256): $(HAS_COMMAND_DOCKER) $(VAR_CTR_IMAGE_GO)
	@$(MAKE) $(DIR_OUT)/dockerbuild/
	@docker build \
		--build-arg FROM=$(CTR_IMAGE_GO) \
		--build-arg GID=$$(id -g) \
		--build-arg UID=$$(id -u) \
		-f $(DIR_ROOT)/Dockerfile.build \
		-t $(CTR_IMAGE_LOCAL) \
		$(DIR_OUT)/dockerbuild
	@touch $(HAS_IMAGE_LOCAL)

$(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE) $(BTRFS_PROGS_URL)

$(DIR_OUT)/$(CHRONY_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(CHRONY_ARCHIVE) $(CHRONY_URL)

$(DIR_OUT)/$(E2FSPROGS_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(E2FSPROGS_ARCHIVE) $(E2FSPROGS_URL)

$(DIR_OUT)/$(KERNEL_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(KERNEL_ARCHIVE) $(KERNEL_URL)

$(DIR_OUT)/$(OPENSSH_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(OPENSSH_ARCHIVE) $(OPENSSH_URL)

$(DIR_OUT)/$(OPENSSL_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(OPENSSL_ARCHIVE) $(OPENSSL_URL)

$(DIR_OUT)/$(PACKER_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(PACKER_ARCHIVE) $(PACKER_URL)

$(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE) $(PACKER_PLUGIN_AMZ_URL)

$(DIR_OUT)/$(SUDO_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(SUDO_ARCHIVE) $(SUDO_URL)

$(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE) $(SYSTEMD_BOOT_URL)

$(DIR_OUT)/$(UTIL_LINUX_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(UTIL_LINUX_ARCHIVE) $(UTIL_LINUX_URL)

$(DIR_OUT)/$(ZLIB_ARCHIVE): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(ZLIB_ARCHIVE) $(ZLIB_URL)

$(DIR_OUT)/$(BUSYBOX_BIN): $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(BUSYBOX_BIN) $(BUSYBOX_URL)

$(DIR_OUT)/$(BTRFS_PROGS_SRC): $(HAS_COMMAND_XZCAT) $(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE)
	@xzcat $(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE) | tar xf - -C $(DIR_OUT)

$(DIR_OUT)/$(CHRONY_SRC): $(DIR_OUT)/$(CHRONY_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(CHRONY_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(E2FSPROGS_SRC): $(DIR_OUT)/$(E2FSPROGS_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(E2FSPROGS_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(KERNEL_SRC): $(HAS_COMMAND_XZCAT) $(DIR_OUT)/$(KERNEL_ARCHIVE)
	@xzcat $(DIR_OUT)/$(KERNEL_ARCHIVE) | tar xf - -C $(DIR_OUT)

$(DIR_OUT)/$(OPENSSH_SRC): $(DIR_OUT)/$(OPENSSH_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(OPENSSH_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(OPENSSL_SRC): $(DIR_OUT)/$(OPENSSL_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(OPENSSL_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(SUDO_SRC): $(DIR_OUT)/$(SUDO_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(SUDO_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(UTIL_LINUX_SRC): $(DIR_OUT)/$(UTIL_LINUX_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(UTIL_LINUX_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(ZLIB_SRC): $(DIR_OUT)/$(ZLIB_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(ZLIB_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/bin/mkfs.btrfs.static: $(BTRFS_PROGS_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(BTRFS_PROGS_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS):/$(DIR_TMPINSTALL_BTRFS_PROGS) \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX):/$(DIR_TMPINSTALL_UTIL_LINUX) \
		-v $(DIR_ROOT)/hack/functions:/functions \
		-e DIR_TMPINSTALL_BTRFS_PROGS=/$(DIR_TMPINSTALL_BTRFS_PROGS) \
		-e DIR_TMPINSTALL_UTIL_LINUX=/$(DIR_TMPINSTALL_UTIL_LINUX) \
		-e PKG_CONFIG_PATH=/$(DIR_TMPINSTALL_UTIL_LINUX)/lib/pkgconfig \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-btrfsprogs-ctr)"

$(CHRONY_BUILD_OUT) &: $(CHRONY_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/$(DIR_ET)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(CHRONY_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY):/$(DIR_TMPINSTALL_CHRONY) \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/$(DIR_ET):/$(DIR_ET) \
		-e DIR_TMPINSTALL_CHRONY=/$(DIR_TMPINSTALL_CHRONY) \
		-e CHRONY_USER=$(CHRONY_USER) \
		-e CHRONYRUNDIR=/$(DIR_ET)/run/chrony \
		-e LOCALSTATEDIR=/$(DIR_ET)/var \
		-e SYSCONFDIR=/$(DIR_ET)/etc \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-chrony-ctr)"

$(E2FSPROGS_BUILD_OUT) &: $(E2FSPROGS_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(E2FSPROGS_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS):/$(DIR_TMPINSTALL_E2FSPROGS) \
		-e DIR_TMPINSTALL_E2FSPROGS=/$(DIR_TMPINSTALL_E2FSPROGS) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-e2fsprogs-ctr)"

$(OPENSSH_BUILD_OUT) &: $(OPENSSH_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/$(DIR_ET)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(OPENSSH_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH):/$(DIR_TMPINSTALL_OPENSSH) \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/$(DIR_ET):/$(DIR_ET) \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL):/$(DIR_TMPINSTALL_OPENSSL) \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB):/$(DIR_TMPINSTALL_ZLIB) \
		-e OPENSSH_DEFAULT_PATH=$(OPENSSH_DEFAULT_PATH) \
		-e OPENSSH_PRIVSEP_DIR=$(OPENSSH_PRIVSEP_DIR) \
		-e OPENSSH_PRIVSEP_USER=$(OPENSSH_PRIVSEP_USER) \
		-e DIR_TMPINSTALL_OPENSSH=/$(DIR_TMPINSTALL_OPENSSH) \
		-e DIR_TMPINSTALL_OPENSSL=/$(DIR_TMPINSTALL_OPENSSL) \
		-e DIR_TMPINSTALL_ZLIB=/$(DIR_TMPINSTALL_ZLIB) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-openssh-ctr)"

$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL)/lib/libcrypto.a: $(OPENSSL_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(OPENSSL_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL):/$(DIR_TMPINSTALL_OPENSSL) \
		-e DIR_TMPINSTALL_OPENSSL=/$(DIR_TMPINSTALL_OPENSSL) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-openssl-ctr)"

$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/bin/sudo: $(SUDO_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/$(DIR_ET)/run/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(SUDO_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO):/$(DIR_TMPINSTALL_SUDO) \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/$(DIR_ET):/$(DIR_ET) \
		-e DIR_ET=/$(DIR_ET) \
		-e DIR_TMPINSTALL_SUDO=/$(DIR_TMPINSTALL_SUDO) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-sudo-ctr)"

$(UTIL_LINUX_BUILD_OUT) &: $(UTIL_LINUX_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(UTIL_LINUX_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX):/$(DIR_TMPINSTALL_UTIL_LINUX) \
		-e DIR_TMPINSTALL_UTIL_LINUX=/$(DIR_TMPINSTALL_UTIL_LINUX) \
		-e CFLAGS=-s \
		-e LOCALSTATEDIR=/$(DIR_ET)/var \
		-e RUNSTATEDIR=/$(DIR_ET)/run \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-util-linux-ctr)"

$(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB)/lib/libz.a: $(ZLIB_BUILD_DEPS)
	@$(MAKE) $(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(ZLIB_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB):/$(DIR_TMPINSTALL_ZLIB) \
		-e DIR_TMPINSTALL_ZLIB=/$(DIR_TMPINSTALL_ZLIB) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-zlib-ctr)"

$(DIR_STG_BASE)/$(DIR_ET)/bin/busybox: $(DIR_OUT)/$(BUSYBOX_BIN) $(VAR_DIR_ET)
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/bin/
	@install -m 0755 $(DIR_OUT)/$(BUSYBOX_BIN) $(DIR_STG_BASE)/$(DIR_ET)/bin/busybox

$(DIR_STG_BASE)/$(DIR_ET)/bin/sh: files/bin/sh $(DIR_STG_BASE)/$(DIR_ET)/bin/busybox $(VAR_DIR_ET)
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/bin/sh > $(DIR_STG_BASE)/$(DIR_ET)/bin/sh
	@chmod 0755 $(DIR_STG_BASE)/$(DIR_ET)/bin/sh

$(DIR_STG_BASE)/$(DIR_ET)/etc/amazon.pem: files/etc/amazon.pem $(VAR_DIR_ET)
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/etc/
	@install -m 0644 files/etc/amazon.pem $(DIR_STG_BASE)/$(DIR_ET)/etc/amazon.pem

$(DIR_STG_BASE)/$(DIR_ET)/libexec/blkid: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/sbin/blkid.static
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/libexec/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/sbin/blkid.static \
		$(DIR_STG_BASE)/$(DIR_ET)/libexec/blkid

$(DIR_STG_BASE)/$(DIR_ET)/sbin/blkid: $(DIR_STG_BASE)/$(DIR_ET)/libexec/blkid files/sbin/blkid
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/sbin/blkid > $(DIR_STG_BASE)/$(DIR_ET)/sbin/blkid
	@chmod 0755 $(DIR_STG_BASE)/$(DIR_ET)/sbin/blkid

$(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/mke2fs
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/mke2fs \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs

$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.ext%: $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs $(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.ext$*

$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.btrfs: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/bin/mkfs.btrfs.static
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@install -m 0755 \
		$(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/bin/mkfs.btrfs.static \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.btrfs

$(DIR_STG_BASE)/$(DIR_ET)/sbin/resize2fs: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/resize2fs
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/resize2fs \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/resize2fs

$(DIR_STG_BOOTLOADER)/boot/EFI/BOOT/BOOTX64.EFI: $(HAS_IMAGE_LOCAL) $(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE)
	@$(MAKE) $(DIR_STG_BOOTLOADER)/boot/EFI/BOOT/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE):/$(SYSTEMD_BOOT_ARCHIVE) \
		-v $(DIR_ROOT)/$(DIR_STG_BOOTLOADER):/staging \
		-e SYSTEMD_BOOT_ARCHIVE=/$(SYSTEMD_BOOT_ARCHIVE) \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/extract-bootloader-ctr)"

$(DIR_STG_CHRONY)/$(DIR_ET)/sbin/chronyd: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/sbin/chronyd
	@$(MAKE) $(DIR_STG_CHRONY)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/sbin/chronyd \
		$(DIR_STG_CHRONY)/$(DIR_ET)/sbin/chronyd

$(DIR_STG_CHRONY)/$(DIR_ET)/bin/chronyc: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/bin/chronyc
	@$(MAKE) $(DIR_STG_CHRONY)/$(DIR_ET)/bin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/bin/chronyc \
		$(DIR_STG_CHRONY)/$(DIR_ET)/bin/chronyc

$(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf: files/etc/chrony.conf $(VAR_DIR_ET)
	@$(MAKE) $(DIR_STG_CHRONY)/$(DIR_ET)/etc/
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/etc/chrony.conf > $(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf
	@chmod 0644 $(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf

$(DIR_STG_CHRONY)/$(DIR_ET)/services/chrony: $(VAR_DIR_ET)
	@$(MAKE) $(DIR_STG_CHRONY)/$(DIR_ET)/services/
	@touch $(DIR_STG_CHRONY)/$(DIR_ET)/services/chrony

# Other files are created by the kernel build, but vmlinuz-$(KERNEL_VERSION) is used
# here to indicate the target was created. It is the last file created by the build
# via the $(DIR_ROOT)/kernel/installkernel script mounted in the build container.
# N.B. The kernel build target differs from others in that it installs directly into
# the staging area, whereas the others install into a tmpinstall directory so select
# files can be chosen to be put into the staging area.
$(DIR_STG_KERNEL)/boot/vmlinuz-$(KERNEL_VERSION): $(KERNEL_BUILD_DEPS)
	@$(MAKE) $(DIR_STG_KERNEL)/boot/ $(DIR_STG_KERNEL)/$(DIR_ET)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(KERNEL_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_STG_KERNEL):/install \
		-v $(DIR_ROOT)/kernel/config:/config \
		-v $(DIR_ROOT)/kernel/installkernel:/sbin/installkernel \
		-e INSTALL_PATH=/install/boot \
		-e INSTALL_MOD_PATH=/install/$(DIR_ET) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-kernel-ctr)"
	@rm -f $(DIR_STG_KERNEL)/$(DIR_ET)/lib/modules/$(KERNEL_VERSION)/build
	@rm -f $(DIR_STG_KERNEL)/$(DIR_ET)/lib/modules/$(KERNEL_VERSION)/source

$(DIR_STG_SSH)/$(DIR_ET)/bin/ssh-keygen: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/bin/ssh-keygen
	@$(MAKE) $(DIR_STG_SSH)/$(DIR_ET)/bin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/bin/ssh-keygen \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/ssh-keygen

$(DIR_STG_SSH)/$(DIR_ET)/bin/sudo: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/bin/sudo
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/bin/
	@install -m 4511 $(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/bin/sudo \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/sudo

$(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config: files/etc/ssh/sshd_config $(VAR_DIR_ET)
	@$(MAKE) $(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/etc/ssh/sshd_config > $(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config
	@chmod 0600 $(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config

$(DIR_STG_SSH)/$(DIR_ET)/etc/sudoers: files/etc/sudoers $(VAR_DIR_ET)
	@$(MAKE) $(DIR_STG_BASE)/$(DIR_ET)/etc/
	@install -m 0440 files/etc/sudoers $(DIR_STG_SSH)/$(DIR_ET)/etc/sudoers

$(DIR_STG_SSH)/$(DIR_ET)/libexec/sftp-server: $(VAR_DIR_ET) \
		$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/libexec/sftp-server
	@$(MAKE) $(DIR_STG_SSH)/$(DIR_ET)/libexec/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/libexec/sftp-server \
		$(DIR_STG_SSH)/$(DIR_ET)/libexec/sftp-server

$(DIR_STG_SSH)/$(DIR_ET)/sbin/sshd: $(VAR_DIR_ET) $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/sbin/sshd
	@$(MAKE) $(DIR_STG_SSH)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/sbin/sshd \
		$(DIR_STG_SSH)/$(DIR_ET)/sbin/sshd

$(DIR_STG_SSH)/$(DIR_ET)/services/ssh: $(VAR_DIR_ET)
	@$(MAKE) $(DIR_STG_SSH)/$(DIR_ET)/services/
	@touch $(DIR_STG_SSH)/$(DIR_ET)/services/ssh

$(DIR_RELEASE_RUNTIME)/boot.tar: $(HAS_COMMAND_FAKEROOT) $(DIR_STG_BOOTLOADER)/boot/EFI/BOOT/BOOTX64.EFI
	@$(MAKE) $(DIR_RELEASE_RUNTIME)/ $(DIR_STG_BOOTLOADER)/boot/loader/entries/
	@chmod -R 0755 $(DIR_STG_BOOTLOADER)
	@cd $(DIR_STG_BOOTLOADER) && fakeroot tar cf $(DIR_ROOT)/$(DIR_RELEASE_RUNTIME)/boot.tar .

$(DIR_RELEASE_RUNTIME)/base.tar: \
		$(HAS_COMMAND_FAKEROOT) \
		$(DIR_STG_BASE)/$(DIR_ET)/bin/busybox \
		$(DIR_STG_BASE)/$(DIR_ET)/bin/sh \
		$(DIR_STG_BASE)/$(DIR_ET)/etc/amazon.pem \
		$(DIR_STG_BASE)/$(DIR_ET)/libexec/blkid \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/blkid \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.btrfs \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.ext2 \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.ext3 \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.ext4 \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/resize2fs
	@$(MAKE) $(DIR_RELEASE_RUNTIME)/
	@cd $(DIR_STG_BASE) && fakeroot tar cf $(DIR_ROOT)/$(DIR_RELEASE_RUNTIME)/base.tar .

$(DIR_RELEASE_RUNTIME)/chrony.tar: \
		$(HAS_COMMAND_FAKEROOT) \
		$(DIR_STG_CHRONY)/$(DIR_ET)/bin/chronyc \
		$(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf \
		$(DIR_STG_CHRONY)/$(DIR_ET)/sbin/chronyd \
		$(DIR_STG_CHRONY)/$(DIR_ET)/services/chrony
	@$(MAKE) $(DIR_RELEASE_RUNTIME)/
	@cd $(DIR_STG_CHRONY) && fakeroot tar cf $(DIR_ROOT)/$(DIR_RELEASE_RUNTIME)/chrony.tar .

$(DIR_RELEASE_RUNTIME)/kernel.tar: $(HAS_COMMAND_FAKEROOT) \
		$(DIR_STG_KERNEL)/boot/vmlinuz-$(KERNEL_VERSION)
	@$(MAKE) $(DIR_RELEASE_RUNTIME)/
	@cd $(DIR_STG_KERNEL) && fakeroot tar -cf $(DIR_ROOT)/$(DIR_RELEASE_RUNTIME)/kernel.tar .

$(DIR_RELEASE_RUNTIME)/ssh.tar: \
		$(HAS_COMMAND_FAKEROOT) \
		$(DIR_STG_SSH)/$(DIR_ET)/libexec/sftp-server \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/ssh-keygen \
		$(DIR_STG_SSH)/$(DIR_ET)/sbin/sshd \
		$(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config \
		$(DIR_STG_SSH)/$(DIR_ET)/services/ssh \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/sudo \
		$(DIR_STG_SSH)/$(DIR_ET)/etc/sudoers
	@$(MAKE) $(DIR_RELEASE_RUNTIME)/
	@cd $(DIR_STG_SSH) && fakeroot tar cpf $(DIR_ROOT)/$(DIR_RELEASE_RUNTIME)/ssh.tar .

PACKER_ASSETS = $(DIR_RELEASE_PACKER)/$(PACKER_EXE) \
	$(DIR_RELEASE_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)_SHA256SUM

$(DIR_RELEASE)/$(PROJECT)-packer-$(VERSION)-$(OS)-$(ARCH).tar.gz: $(HAS_COMMAND_FAKEROOT) \
		$(PACKER_ASSETS)
	@[ -n "$(VERSION)" ] || (echo "VERSION is required"; exit 1)
	@[ $$(echo $(VERSION) | cut -c 1) = v ] || (echo "VERSION must begin with a 'v'"; exit 1)
	@cd $(DIR_RELEASE_PACKER) && \
		fakeroot tar -cz \
		--xform "s|^|$(PROJECT)-packer-$(VERSION)-$(OS)-$(ARCH)/|" \
		-f $(DIR_ROOT)/$(DIR_RELEASE)/$(PROJECT)-packer-$(VERSION)-$(OS)-$(ARCH).tar.gz .

$(DIR_RELEASE)/$(PROJECT)-runtime-$(VERSION).tar.gz: $(HAS_COMMAND_FAKEROOT) \
		$(DIR_RELEASE_RUNTIME)/base.tar \
		$(DIR_RELEASE_RUNTIME)/boot.tar \
		$(DIR_RELEASE_RUNTIME)/chrony.tar \
		$(DIR_RELEASE_RUNTIME)/ssh.tar \
		$(DIR_RELEASE_RUNTIME)/kernel.tar
	@[ -n "$(VERSION)" ] || (echo "VERSION is required"; exit 1)
	@[ $$(echo $(VERSION) | cut -c 1) = v ] || (echo "VERSION must begin with a 'v'"; exit 1)
	@cd $(DIR_RELEASE_RUNTIME) && \
		fakeroot tar -cz \
		--xform "s|^|$(PROJECT)-runtime-$(VERSION)/|" \
		-f $(DIR_ROOT)/$(DIR_RELEASE)/$(PROJECT)-runtime-$(VERSION).tar.gz .

$(DIR_RELEASE_PACKER)/$(PACKER_EXE): $(HAS_COMMAND_UNZIP) $(DIR_OUT)/$(PACKER_ARCHIVE)
	@$(MAKE) $(DIR_RELEASE_PACKER)/
	@unzip -o $(DIR_OUT)/$(PACKER_ARCHIVE) -d $(DIR_RELEASE_PACKER)
	@touch $(DIR_RELEASE_PACKER)/$(PACKER_EXE)

$(DIR_RELEASE_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)_SHA256SUM: $(DIR_RELEASE_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)
	@sha256sum $(DIR_RELEASE_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE) | \
		awk '{print $$1}' > $(DIR_RELEASE_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)_SHA256SUM

$(DIR_RELEASE_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE): $(HAS_COMMAND_UNZIP) \
		$(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE)
	@$(MAKE) $(DIR_RELEASE_PACKER_PLUGIN)/
	@unzip -o $(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE) -d $(DIR_RELEASE_PACKER_PLUGIN)
	@touch $(DIR_RELEASE_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)

release-packer-one: $(DIR_RELEASE)/$(PROJECT)-packer-$(VERSION)-$(OS)-$(ARCH).tar.gz

release-packer-linux-%:
	$(MAKE) OS=linux ARCH=$* VERSION=$(VERSION) release-packer-one

release-packer-darwin-%:
	$(MAKE) OS=darwin ARCH=$* VERSION=$(VERSION) release-packer-one

release-packer-windows-%:
	$(MAKE) OS=windows ARCH=$* VERSION=$(VERSION) release-packer-one

release-packer: release-packer-linux-amd64 release-packer-linux-arm64 \
	release-packer-darwin-amd64 release-packer-darwin-arm64 \
	release-packer-windows-amd64

release-runtime: $(DIR_RELEASE)/$(PROJECT)-runtime-$(VERSION).tar.gz

release: release-packer release-runtime

clean:
	@chmod -R +w $(DIR_OUT)/go
	@rm -rf $(DIR_OUT)
