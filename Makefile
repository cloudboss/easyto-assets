PROJECT = $(shell basename ${PWD})
OS = $(shell uname | tr [:upper:] [:lower:])
ARCH = $(shell arch=$$(uname -m); [ "$${arch}" = "x86_64" ] && echo "amd64" || echo $${arch})
VERSION =
DIR_OUT = _output

DIR_STG = $(DIR_OUT)/staging
DIR_STG_BOOTLOADER = $(DIR_STG)/bootloader
DIR_STG_BASE = $(DIR_STG)/base
DIR_STG_CHRONY = $(DIR_STG)/chrony
DIR_STG_KERNEL = $(DIR_STG)/kernel
DIR_STG_SSH = $(DIR_STG)/ssh
DIR_STG_PACKER = $(DIR_STG)/packer/$(OS)/$(ARCH)
DIR_STG_PACKER_PLUGIN = $(DIR_STG_PACKER)/plugins/github.com/hashicorp/amazon
DIR_STG_RUNTIME = $(DIR_STG)/runtime
DIRS_STG_CLEAN = $(DIR_STG_BASE) $(DIR_STG_CHRONY) $(DIR_STG_KERNEL) $(DIR_STG_SSH)

include Makefile.inc

DIR_RELEASE = $(DIR_OUT)/release

DIR_TMPINSTALL_BTRFS_PROGS = btrfs-progs-tmpinstall
DIR_TMPINSTALL_CHRONY = chrony-tmpinstall
DIR_TMPINSTALL_E2FSPROGS = e2fsprogs-tmpinstall
DIR_TMPINSTALL_KMOD = kmod-tmpinstall
DIR_TMPINSTALL_OPENSSH = openssh-tmpinstall
DIR_TMPINSTALL_OPENSSL = openssl-tmpinstall
DIR_TMPINSTALL_SUDO = sudo-tmpinstall
DIR_TMPINSTALL_UTIL_LINUX = util-linux-tmpinstall
DIR_TMPINSTALL_ZLIB = zlib-tmpinstall

KERNEL_ORG = https://cdn.kernel.org/pub/linux

BTRFS_PROGS_VERSION = 6.5.2
BTRFS_PROGS_SRC = btrfs-progs-v$(BTRFS_PROGS_VERSION)
BTRFS_PROGS_ARCHIVE = $(BTRFS_PROGS_SRC).tar.xz
BTRFS_PROGS_URL = $(KERNEL_ORG)/kernel/people/kdave/btrfs-progs/$(BTRFS_PROGS_ARCHIVE)

E2FSPROGS_VERSION = 1.47.0
E2FSPROGS_SRC = e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_ARCHIVE = $(E2FSPROGS_SRC).tar.gz
E2FSPROGS_URL = $(KERNEL_ORG)/kernel/people/tytso/e2fsprogs/v$(E2FSPROGS_VERSION)/$(E2FSPROGS_ARCHIVE)

KERNEL_VERSION = 6.6.29
KERNEL_VERSION_MAJ = $(shell echo $(KERNEL_VERSION) | cut -c 1)
KERNEL_SRC = linux-$(KERNEL_VERSION)
KERNEL_ARCHIVE = $(KERNEL_SRC).tar.xz
KERNEL_URL = $(KERNEL_ORG)/kernel/v$(KERNEL_VERSION_MAJ).x/$(KERNEL_ARCHIVE)

KMOD_VERSION = af21689dd0f1ef6f40d6ecc323885026a07486f9
KMOD_VERSION_SHORT = $(shell echo $(KMOD_VERSION) | cut -c 1-7)
KMOD_SRC = kmod-project-kmod-$(KMOD_VERSION_SHORT)
KMOD_ARCHIVE = $(KMOD_SRC).tar.gz
KMOD_URL = https://api.github.com/repos/kmod-project/kmod/tarball/$(KMOD_VERSION)

SYSTEMD_BOOT_VERSION = 252.12-1~deb12u1
SYSTEMD_BOOT_ARCHIVE = systemd-boot-efi_$(SYSTEMD_BOOT_VERSION)_amd64.deb
SYSTEMD_BOOT_URL = https://snapshot.debian.org/archive/debian/20230712T091300Z/pool/main/s/systemd/$(SYSTEMD_BOOT_ARCHIVE)

UTIL_LINUX_VERSION = 2.39
UTIL_LINUX_SRC = util-linux-$(UTIL_LINUX_VERSION)
UTIL_LINUX_ARCHIVE = $(UTIL_LINUX_SRC).tar.gz
UTIL_LINUX_URL = $(KERNEL_ORG)/utils/util-linux/v$(UTIL_LINUX_VERSION)/$(UTIL_LINUX_ARCHIVE)

CHRONY_VERSION = 4.5
CHRONY_SRC = chrony-$(CHRONY_VERSION)
CHRONY_ARCHIVE = $(CHRONY_SRC).tar.gz
CHRONY_URL = https://chrony-project.org/releases/$(CHRONY_ARCHIVE)

BUSYBOX_VERSION = 1.35.0
BUSYBOX_URL = https://www.busybox.net/downloads/binaries/$(BUSYBOX_VERSION)-x86_64-linux-musl/busybox
BUSYBOX_BIN = busybox-$(BUSYBOX_VERSION)

ZLIB_VERSION = 1.3.1
ZLIB_SRC = zlib-$(ZLIB_VERSION)
ZLIB_ARCHIVE = $(ZLIB_SRC).tar.gz
ZLIB_URL = https://zlib.net/$(ZLIB_ARCHIVE)

OPENSSL_VERSION = 3.2.1
OPENSSL_SRC = openssl-$(OPENSSL_VERSION)
OPENSSL_ARCHIVE = $(OPENSSL_SRC).tar.gz
OPENSSL_URL = https://www.openssl.org/source/$(OPENSSL_ARCHIVE)

OPENSSH_VERSION = V_9_7_P1
OPENSSH_SRC = openssh-portable-$(OPENSSH_VERSION)
OPENSSH_ARCHIVE = $(OPENSSH_VERSION).tar.gz
OPENSSH_URL = https://github.com/openssh/openssh-portable/archive/refs/tags/$(OPENSSH_ARCHIVE)
OPENSSH_DEFAULT_PATH = /$(DIR_ET)/bin:/$(DIR_ET)/sbin:/bin:/usr/bin:/usr/local/bin

SUDO_VERSION = 1.9.15p5
SUDO_SRC = sudo-$(SUDO_VERSION)
SUDO_ARCHIVE = $(SUDO_SRC).tar.gz
SUDO_URL = https://www.sudo.ws/dist/$(SUDO_ARCHIVE)

PACKER_ARCHIVE = packer_$(PACKER_VERSION)_$(OS)_$(ARCH).zip
PACKER_URL = https://releases.hashicorp.com/packer/$(PACKER_VERSION)/$(PACKER_ARCHIVE)

PACKER_PLUGIN_AMZ_ARCHIVE = $(PACKER_PLUGIN_AMZ_NAME).zip
PACKER_PLUGIN_AMZ_URL = https://github.com/hashicorp/packer-plugin-amazon/releases/download/v$(PACKER_PLUGIN_AMZ_VERSION)/$(PACKER_PLUGIN_AMZ_ARCHIVE)

PACKER_ASSETS = $(DIR_STG_PACKER)/$(PACKER_EXE) \
	$(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE) \
	$(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)_SHA256SUM

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

KMOD_BUILD_DEPS = $(HAS_IMAGE_LOCAL) \
	$(DIR_OUT)/$(KMOD_SRC) \
	hack/compile-kmod-ctr

KMOD_STG_OUT = $(DIR_STG_BASE)/$(DIR_ET)/sbin/depmod \
	$(DIR_STG_BASE)/$(DIR_ET)/sbin/insmod \
	$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod \
	$(DIR_STG_BASE)/$(DIR_ET)/sbin/lsmod \
	$(DIR_STG_BASE)/$(DIR_ET)/sbin/modinfo \
	$(DIR_STG_BASE)/$(DIR_ET)/sbin/modprobe \
	$(DIR_STG_BASE)/$(DIR_ET)/sbin/rmmod

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

.DEFAULT_GOAL = release

$(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE) $(BTRFS_PROGS_URL)

$(DIR_OUT)/$(CHRONY_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(CHRONY_ARCHIVE) $(CHRONY_URL)

$(DIR_OUT)/$(E2FSPROGS_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(E2FSPROGS_ARCHIVE) $(E2FSPROGS_URL)

$(DIR_OUT)/$(KERNEL_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(KERNEL_ARCHIVE) $(KERNEL_URL)

$(DIR_OUT)/$(KMOD_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(KMOD_ARCHIVE) $(KMOD_URL)

$(DIR_OUT)/$(OPENSSH_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(OPENSSH_ARCHIVE) $(OPENSSH_URL)

$(DIR_OUT)/$(OPENSSL_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(OPENSSL_ARCHIVE) $(OPENSSL_URL)

$(DIR_OUT)/$(PACKER_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(PACKER_ARCHIVE) $(PACKER_URL)

$(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE) $(PACKER_PLUGIN_AMZ_URL)

$(DIR_OUT)/$(SUDO_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(SUDO_ARCHIVE) $(SUDO_URL)

$(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE) $(SYSTEMD_BOOT_URL)

$(DIR_OUT)/$(UTIL_LINUX_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(UTIL_LINUX_ARCHIVE) $(UTIL_LINUX_URL)

$(DIR_OUT)/$(ZLIB_ARCHIVE): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(ZLIB_ARCHIVE) $(ZLIB_URL)

$(DIR_OUT)/$(BUSYBOX_BIN): | $(HAS_COMMAND_CURL)
	@curl -L -o $(DIR_OUT)/$(BUSYBOX_BIN) $(BUSYBOX_URL)

$(DIR_OUT)/$(BTRFS_PROGS_SRC): | $(HAS_COMMAND_XZCAT) $(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE)
	@xzcat $(DIR_OUT)/$(BTRFS_PROGS_ARCHIVE) | tar xf - -C $(DIR_OUT)

$(DIR_OUT)/$(CHRONY_SRC): $(DIR_OUT)/$(CHRONY_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(CHRONY_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(E2FSPROGS_SRC): $(DIR_OUT)/$(E2FSPROGS_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(E2FSPROGS_ARCHIVE) -C $(DIR_OUT)

$(DIR_OUT)/$(KERNEL_SRC): $(DIR_OUT)/$(KERNEL_ARCHIVE) | $(HAS_COMMAND_XZCAT)
	@xzcat $(DIR_OUT)/$(KERNEL_ARCHIVE) | tar xf - -C $(DIR_OUT)

$(DIR_OUT)/$(KMOD_SRC): | $(DIR_OUT)/$(KMOD_ARCHIVE)
	@tar zxmf $(DIR_OUT)/$(KMOD_ARCHIVE) -C $(DIR_OUT)

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

$(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/bin/mkfs.btrfs.static: \
		$(BTRFS_PROGS_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/
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

$(CHRONY_BUILD_OUT) &: \
		$(CHRONY_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/$(DIR_ET)/
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

$(E2FSPROGS_BUILD_OUT) &: \
		$(E2FSPROGS_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(E2FSPROGS_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS):/$(DIR_TMPINSTALL_E2FSPROGS) \
		-e DIR_TMPINSTALL_E2FSPROGS=/$(DIR_TMPINSTALL_E2FSPROGS) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-e2fsprogs-ctr)"

$(DIR_OUT)/$(DIR_TMPINSTALL_KMOD)/bin/kmod: \
		$(KMOD_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_KMOD)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(KMOD_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_KMOD):/$(DIR_TMPINSTALL_KMOD) \
		-e DIR_MODULES=/$(DIR_ET)/lib/modules \
		-e DIR_TMPINSTALL_KMOD=/$(DIR_TMPINSTALL_KMOD) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-kmod-ctr)"

$(OPENSSH_BUILD_OUT) &: \
		$(OPENSSH_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/$(DIR_ET)/
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

$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL)/lib/libcrypto.a: \
		$(OPENSSL_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(OPENSSL_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSL):/$(DIR_TMPINSTALL_OPENSSL) \
		-e DIR_TMPINSTALL_OPENSSL=/$(DIR_TMPINSTALL_OPENSSL) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-openssl-ctr)"

$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/bin/sudo: \
		$(SUDO_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/$(DIR_ET)/run/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(SUDO_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO):/$(DIR_TMPINSTALL_SUDO) \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/$(DIR_ET):/$(DIR_ET) \
		-e DIR_ET=/$(DIR_ET) \
		-e DIR_TMPINSTALL_SUDO=/$(DIR_TMPINSTALL_SUDO) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-sudo-ctr)"

$(UTIL_LINUX_BUILD_OUT) &: \
		$(UTIL_LINUX_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(UTIL_LINUX_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX):/$(DIR_TMPINSTALL_UTIL_LINUX) \
		-e DIR_TMPINSTALL_UTIL_LINUX=/$(DIR_TMPINSTALL_UTIL_LINUX) \
		-e CFLAGS=-s \
		-e LOCALSTATEDIR=/$(DIR_ET)/var \
		-e RUNSTATEDIR=/$(DIR_ET)/run \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-util-linux-ctr)"

$(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB)/lib/libz.a: \
		$(ZLIB_BUILD_DEPS) \
		| $(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB)/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(ZLIB_SRC):/code \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(DIR_TMPINSTALL_ZLIB):/$(DIR_TMPINSTALL_ZLIB) \
		-e DIR_TMPINSTALL_ZLIB=/$(DIR_TMPINSTALL_ZLIB) \
		-w /code \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/compile-zlib-ctr)"

$(DIR_STG_BASE)/$(DIR_ET)/bin/busybox: \
		$(DIR_OUT)/$(BUSYBOX_BIN) \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/bin/
	@install -m 0755 $(DIR_OUT)/$(BUSYBOX_BIN) $(DIR_STG_BASE)/$(DIR_ET)/bin/busybox

$(DIR_STG_BASE)/$(DIR_ET)/bin/sh: \
		files/bin/sh \
		$(DIR_STG_BASE)/$(DIR_ET)/bin/busybox \
		| $(VAR_DIR_ET)
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/bin/sh > $(DIR_STG_BASE)/$(DIR_ET)/bin/sh
	@chmod 0755 $(DIR_STG_BASE)/$(DIR_ET)/bin/sh

$(DIR_STG_BASE)/$(DIR_ET)/etc/amazon.pem: \
		files/etc/amazon.pem \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/etc/
	@install -m 0644 files/etc/amazon.pem $(DIR_STG_BASE)/$(DIR_ET)/etc/amazon.pem

$(DIR_STG_BASE)/$(DIR_ET)/libexec/blkid: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/sbin/blkid.static \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/libexec/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_UTIL_LINUX)/sbin/blkid.static \
		$(DIR_STG_BASE)/$(DIR_ET)/libexec/blkid

$(DIR_STG_BASE)/$(DIR_ET)/sbin/blkid: \
		$(DIR_STG_BASE)/$(DIR_ET)/libexec/blkid \
		files/sbin/blkid \
		| $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/sbin/blkid > $(DIR_STG_BASE)/$(DIR_ET)/sbin/blkid
	@chmod 0755 $(DIR_STG_BASE)/$(DIR_ET)/sbin/blkid

$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_KMOD)/bin/kmod \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_KMOD)/bin/kmod \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod

$(DIR_STG_BASE)/$(DIR_ET)/sbin/depmod: \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod $(DIR_STG_BASE)/$(DIR_ET)/sbin/depmod

$(DIR_STG_BASE)/$(DIR_ET)/sbin/insmod: \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod $(DIR_STG_BASE)/$(DIR_ET)/sbin/insmod

$(DIR_STG_BASE)/$(DIR_ET)/sbin/lsmod: \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod $(DIR_STG_BASE)/$(DIR_ET)/sbin/lsmod

$(DIR_STG_BASE)/$(DIR_ET)/sbin/modinfo: \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod $(DIR_STG_BASE)/$(DIR_ET)/sbin/modinfo

$(DIR_STG_BASE)/$(DIR_ET)/sbin/modprobe: \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod $(DIR_STG_BASE)/$(DIR_ET)/sbin/modprobe

$(DIR_STG_BASE)/$(DIR_ET)/sbin/rmmod: \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/kmod $(DIR_STG_BASE)/$(DIR_ET)/sbin/rmmod

$(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/mke2fs \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/mke2fs \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs

$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.ext%: \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@ln -f $(DIR_STG_BASE)/$(DIR_ET)/sbin/mke2fs $(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.ext$*

$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.btrfs: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/bin/mkfs.btrfs.static \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@install -m 0755 \
		$(DIR_OUT)/$(DIR_TMPINSTALL_BTRFS_PROGS)/bin/mkfs.btrfs.static \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/mkfs.btrfs

$(DIR_STG_BASE)/$(DIR_ET)/sbin/resize2fs: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/resize2fs \
		| $(VAR_DIR_ET) $(DIR_STG_BASE)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_E2FSPROGS)/sbin/resize2fs \
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/resize2fs

$(DIR_STG_BOOTLOADER)/boot/EFI/BOOT/BOOTX64.EFI: \
		$(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE) \
		| $(HAS_IMAGE_LOCAL) $(DIR_STG_BOOTLOADER)/boot/EFI/BOOT/
	@docker run --rm -t \
		-v $(DIR_ROOT)/$(DIR_OUT)/$(SYSTEMD_BOOT_ARCHIVE):/$(SYSTEMD_BOOT_ARCHIVE) \
		-v $(DIR_ROOT)/$(DIR_STG_BOOTLOADER):/staging \
		-e SYSTEMD_BOOT_ARCHIVE=/$(SYSTEMD_BOOT_ARCHIVE) \
		$(CTR_IMAGE_LOCAL) /bin/sh -c "$$(cat hack/extract-bootloader-ctr)"

$(DIR_STG_CHRONY)/$(DIR_ET)/sbin/chronyd: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/sbin/chronyd \
		| $(VAR_DIR_ET) $(DIR_STG_CHRONY)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/sbin/chronyd \
		$(DIR_STG_CHRONY)/$(DIR_ET)/sbin/chronyd

$(DIR_STG_CHRONY)/$(DIR_ET)/bin/chronyc: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/bin/chronyc \
		| $(VAR_DIR_ET) $(DIR_STG_CHRONY)/$(DIR_ET)/bin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_CHRONY)/bin/chronyc \
		$(DIR_STG_CHRONY)/$(DIR_ET)/bin/chronyc

$(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf: \
		files/etc/chrony.conf \
		| $(VAR_DIR_ET) $(DIR_STG_CHRONY)/$(DIR_ET)/etc/
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/etc/chrony.conf > $(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf
	@chmod 0644 $(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf

$(DIR_STG_CHRONY)/$(DIR_ET)/services/chrony: \
		| $(VAR_DIR_ET) $(DIR_STG_CHRONY)/$(DIR_ET)/services/
	@touch $(DIR_STG_CHRONY)/$(DIR_ET)/services/chrony

# Other files are created by the kernel build, but vmlinuz-$(KERNEL_VERSION) is used
# here to indicate the target was created. It is the last file created by the build
# via the $(DIR_ROOT)/kernel/installkernel script mounted in the build container.
# N.B. The kernel build target differs from others in that it installs directly into
# the staging area, whereas the others install into a tmpinstall directory so select
# files can be chosen to be put into the staging area.
$(DIR_STG_KERNEL)/boot/vmlinuz-$(KERNEL_VERSION): \
		$(KERNEL_BUILD_DEPS) \
		| $(DIR_STG_KERNEL)/boot/ $(DIR_STG_KERNEL)/$(DIR_ET)/
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

$(DIR_STG_SSH)/$(DIR_ET)/bin/ssh-keygen: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/bin/ssh-keygen \
		| $(VAR_DIR_ET) $(DIR_STG_SSH)/$(DIR_ET)/bin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/bin/ssh-keygen \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/ssh-keygen

$(DIR_STG_SSH)/$(DIR_ET)/bin/sudo: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/bin/sudo \
		| $(VAR_DIR_ET) $(DIR_STG_SSH)/$(DIR_ET)/bin/
	@install -m 4511 $(DIR_OUT)/$(DIR_TMPINSTALL_SUDO)/bin/sudo \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/sudo

$(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config: \
		files/etc/ssh/sshd_config \
		| $(VAR_DIR_ET) $(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/
	@sed "s|__DIR_ET__|/${DIR_ET}|g" files/etc/ssh/sshd_config > $(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config
	@chmod 0600 $(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config

$(DIR_STG_SSH)/$(DIR_ET)/etc/sudoers: \
		files/etc/sudoers \
		| $(VAR_DIR_ET) $(DIR_STG_SSH)/$(DIR_ET)/etc/
	@install -m 0440 files/etc/sudoers $(DIR_STG_SSH)/$(DIR_ET)/etc/sudoers

$(DIR_STG_SSH)/$(DIR_ET)/libexec/sftp-server: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/libexec/sftp-server \
		| $(VAR_DIR_ET) $(DIR_STG_SSH)/$(DIR_ET)/libexec/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/libexec/sftp-server \
		$(DIR_STG_SSH)/$(DIR_ET)/libexec/sftp-server

$(DIR_STG_SSH)/$(DIR_ET)/sbin/sshd: \
		$(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/sbin/sshd \
		| $(VAR_DIR_ET) $(DIR_STG_SSH)/$(DIR_ET)/sbin/
	@install -m 0755 $(DIR_OUT)/$(DIR_TMPINSTALL_OPENSSH)/sbin/sshd \
		$(DIR_STG_SSH)/$(DIR_ET)/sbin/sshd

$(DIR_STG_SSH)/$(DIR_ET)/services/ssh: \
		| $(VAR_DIR_ET) $(DIR_STG_SSH)/$(DIR_ET)/services/
	@touch $(DIR_STG_SSH)/$(DIR_ET)/services/ssh

$(DIR_STG_PACKER)/$(PACKER_EXE): \
		$(DIR_OUT)/$(PACKER_ARCHIVE) \
		| $(HAS_COMMAND_UNZIP) $(DIR_STG_PACKER)/
	@unzip -o $(DIR_OUT)/$(PACKER_ARCHIVE) -d $(DIR_STG_PACKER)
	@touch $(DIR_STG_PACKER)/$(PACKER_EXE)

$(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE): \
		$(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE) \
		| $(HAS_COMMAND_UNZIP) $(DIR_STG_PACKER_PLUGIN)/
	@unzip -o $(DIR_OUT)/$(PACKER_PLUGIN_AMZ_ARCHIVE) -d $(DIR_STG_PACKER_PLUGIN)
	@touch $(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)

$(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)_SHA256SUM: \
		$(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)
	@sha256sum $(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE) | \
		awk '{print $$1}' > $(DIR_STG_PACKER_PLUGIN)/$(PACKER_PLUGIN_AMZ_EXE)_SHA256SUM

$(DIR_STG_RUNTIME)/base.tar: \
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
		$(DIR_STG_BASE)/$(DIR_ET)/sbin/resize2fs \
		$(KMOD_STG_OUT) \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_STG_RUNTIME)/
	@cd $(DIR_STG_BASE) && fakeroot tar cf $(DIR_ROOT)/$(DIR_STG_RUNTIME)/base.tar .

$(DIR_STG_RUNTIME)/boot.tar: \
		$(DIR_STG_BOOTLOADER)/boot/EFI/BOOT/BOOTX64.EFI \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_STG_RUNTIME)/ $(DIR_STG_BOOTLOADER)/boot/loader/entries/
	@chmod -R 0755 $(DIR_STG_BOOTLOADER)
	@cd $(DIR_STG_BOOTLOADER) && fakeroot tar cf $(DIR_ROOT)/$(DIR_STG_RUNTIME)/boot.tar .

$(DIR_STG_RUNTIME)/chrony.tar: \
		$(DIR_STG_CHRONY)/$(DIR_ET)/bin/chronyc \
		$(DIR_STG_CHRONY)/$(DIR_ET)/etc/chrony.conf \
		$(DIR_STG_CHRONY)/$(DIR_ET)/sbin/chronyd \
		$(DIR_STG_CHRONY)/$(DIR_ET)/services/chrony \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_STG_RUNTIME)/
	@cd $(DIR_STG_CHRONY) && fakeroot tar cf $(DIR_ROOT)/$(DIR_STG_RUNTIME)/chrony.tar .

$(DIR_STG_RUNTIME)/kernel.tar: \
		$(DIR_STG_KERNEL)/boot/vmlinuz-$(KERNEL_VERSION) \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_STG_RUNTIME)/
	@cd $(DIR_STG_KERNEL) && fakeroot tar -cf $(DIR_ROOT)/$(DIR_STG_RUNTIME)/kernel.tar .

$(DIR_STG_RUNTIME)/ssh.tar: \
		$(DIR_STG_SSH)/$(DIR_ET)/libexec/sftp-server \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/ssh-keygen \
		$(DIR_STG_SSH)/$(DIR_ET)/sbin/sshd \
		$(DIR_STG_SSH)/$(DIR_ET)/etc/ssh/sshd_config \
		$(DIR_STG_SSH)/$(DIR_ET)/services/ssh \
		$(DIR_STG_SSH)/$(DIR_ET)/bin/sudo \
		$(DIR_STG_SSH)/$(DIR_ET)/etc/sudoers \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_STG_RUNTIME)/
	@cd $(DIR_STG_SSH) && fakeroot tar -cpf $(DIR_ROOT)/$(DIR_STG_RUNTIME)/ssh.tar .

$(DIR_RELEASE)/$(PROJECT)-build-$(VERSION).tar.gz: \
		Makefile.inc \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_RELEASE)/
	@[ -n "$(VERSION)" ] || (echo "VERSION is required"; exit 1)
	@[ $$(echo $(VERSION) | cut -c 1) = v ] || (echo "VERSION must begin with a 'v'"; exit 1)
	@fakeroot tar -cz \
		--xform "s|^|$(PROJECT)-build-$(VERSION)/|" \
		-f $(DIR_ROOT)/$(DIR_RELEASE)/$(PROJECT)-build-$(VERSION).tar.gz ./Makefile.inc

$(DIR_RELEASE)/$(PROJECT)-packer-$(VERSION)-$(OS)-$(ARCH).tar.gz: \
		$(PACKER_ASSETS) \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_RELEASE)/
	@[ -n "$(VERSION)" ] || (echo "VERSION is required"; exit 1)
	@[ $$(echo $(VERSION) | cut -c 1) = v ] || (echo "VERSION must begin with a 'v'"; exit 1)
	@cd $(DIR_STG_PACKER) && \
		fakeroot tar -cz \
		--xform "s|^|$(PROJECT)-packer-$(VERSION)-$(OS)-$(ARCH)/|" \
		-f $(DIR_ROOT)/$(DIR_RELEASE)/$(PROJECT)-packer-$(VERSION)-$(OS)-$(ARCH).tar.gz .

$(DIR_RELEASE)/$(PROJECT)-runtime-$(VERSION).tar.gz: \
		$(DIR_STG_RUNTIME)/base.tar \
		$(DIR_STG_RUNTIME)/boot.tar \
		$(DIR_STG_RUNTIME)/chrony.tar \
		$(DIR_STG_RUNTIME)/ssh.tar \
		$(DIR_STG_RUNTIME)/kernel.tar \
		| $(HAS_COMMAND_FAKEROOT) $(DIR_RELEASE)/
	@[ -n "$(VERSION)" ] || (echo "VERSION is required"; exit 1)
	@[ $$(echo $(VERSION) | cut -c 1) = v ] || (echo "VERSION must begin with a 'v'"; exit 1)
	@cd $(DIR_STG_RUNTIME) && \
		fakeroot tar -cz \
		--xform "s|^|$(PROJECT)-runtime-$(VERSION)/|" \
		-f $(DIR_ROOT)/$(DIR_RELEASE)/$(PROJECT)-runtime-$(VERSION).tar.gz .

release-build: $(DIR_RELEASE)/$(PROJECT)-build-$(VERSION).tar.gz

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

release: release-build release-packer release-runtime

clean:
	@chmod -R +w $(DIR_OUT)/go
	@rm -rf $(DIR_OUT)

.PHONY: release-build release-packer-one release-packer \
	release-packer-linux-amd64 release-packer-linux-arm64 \
	release-packer-darwin-amd64 release-packer-darwin-arm64 \
	release-packer-windows-amd64 release-runtime release clean
