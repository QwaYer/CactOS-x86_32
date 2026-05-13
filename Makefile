ROOT := $(abspath ..)

KERN := $(ROOT)/CactKernel-x86_32
REPO := $(ROOT)/LocalRepoCactOS
BRIDGE := $(ROOT)/CactBridge
LIB := $(ROOT)/CactLib-x86_32
SOLE := $(ROOT)/Cactsole-x86_32
CGOCT := $(ROOT)/Cgoct-x86_32
USERBINS := $(ROOT)/CactUserBins-x86_32

JOBS ?= $(shell nproc 2>/dev/null || echo 4)
DRIVERS ?= AHCI NVMe Virtio-net Yukon

ifneq ($(SKIP_DRIVERS),1)
LOCALREPO_PRE := drivers
else
LOCALREPO_PRE :=
endif

.PHONY: all iso kernel localrepo drivers disk clean libc cactsole cgoct userbins

libc:
	@$(MAKE) -s -C "$(LIB)" -j$(JOBS)

cactsole: libc
	@$(MAKE) -s -C "$(SOLE)" -j$(JOBS) CACTLIB="$(LIB)"

cgoct: libc
	@$(MAKE) -s -C "$(CGOCT)" -j$(JOBS) CACTLIB="$(LIB)"

userbins: libc
	@$(MAKE) -s -C "$(USERBINS)" -j$(JOBS) install \
		CACTLIB="$(LIB)" \
		CACTSOLEINC="$(SOLE)/include" \
		LR_BIN="$(REPO)/lib/bin" \
		LR_SBIN="$(REPO)/lib/sbin"

drivers:
	@set -e; for d in $(DRIVERS); do \
		dir="$(ROOT)/$$d-for-Cact"; \
		test -d "$$dir" || continue; \
		$(MAKE) -s -C "$$dir" -j$(JOBS) KERN_ROOT="$(KERN)" LOCAL_REPO="$(REPO)" install; \
	done

localrepo: $(LOCALREPO_PRE) libc cactsole cgoct userbins
	@$(MAKE) -s -C "$(REPO)" -j$(JOBS) \
		CACTLIB_DIR="$(LIB)" \
		CACTSOLE_BIN="$(SOLE)/cactsole" \
		CGOCT_BIN="$(CGOCT)/cgoct" \
		USERBINS_MK="$(USERBINS)" \
		CACTSOLEINC="$(SOLE)/include" \
		LR_BIN="$(REPO)/lib/bin" \
		LR_SBIN="$(REPO)/lib/sbin"

kernel:
	@$(MAKE) -s -C "$(KERN)" -j$(JOBS)

iso: kernel localrepo
	@$(MAKE) -s -C "$(BRIDGE)" iso \
		KERNEL_BIN="$(KERN)/build/kernel.bin" \
		MB2_MODULE_SRC="$(REPO)/cctkfs.img" \
		MB2_MODULE_ISO_NAME="cctkfs.img" \
		MB2_MODULE_CMDLINE="cctkfs"

disk: iso
	@"$(KERN)/build_disk.sh"

all: iso

clean:
	@set -e; for d in $(DRIVERS); do \
		dir="$(ROOT)/$$d-for-Cact"; \
		test -d "$$dir" || continue; \
		$(MAKE) -s -C "$$dir" clean; \
	done
	@$(MAKE) -s -C "$(REPO)" clean
	@$(MAKE) -s -C "$(KERN)" clean
	@$(MAKE) -s -C "$(BRIDGE)" clean
	@$(MAKE) -s -C "$(LIB)" clean
	@$(MAKE) -s -C "$(SOLE)" clean
	@$(MAKE) -s -C "$(CGOCT)" clean
	@$(MAKE) -s -C "$(USERBINS)" clean
