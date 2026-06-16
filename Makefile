ROOT := $(abspath ..)

KERN := $(ROOT)/CactKernel-x86_32
REPO := $(ROOT)/LocalRepoCactOS
BRIDGE := $(ROOT)/CactBridge
LIB := $(ROOT)/CactLib-x86_32
SOLE := $(ROOT)/Cactsole-x86_32
CGOCT := $(ROOT)/Cgoct-x86_32
CGOCT_GUI := $(ROOT)/Cgoct-gui-x86_32
USERBINS := $(ROOT)/CactUserBins-x86_32
XFBDEV := $(ROOT)/CactXfbdev-x86_32
OPTICS := $(ROOT)/Optics

JOBS ?= $(shell nproc 2>/dev/null || echo 4)
DRIVERS ?= AHCI NVMe Virtio-net Yukon

ifneq ($(SKIP_DRIVERS),1)
LOCALREPO_PRE := drivers
else
LOCALREPO_PRE :=
endif

.PHONY: all iso iso-gui kernel localrepo drivers disk clean libc cactsole cgoct userbins xfbdev

.DEFAULT_GOAL := iso-gui

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

xfbdev: libc
	@$(MAKE) -s -C "$(XFBDEV)" -j$(JOBS) \
		CACTLIB="$(LIB)"

localrepo: $(LOCALREPO_PRE) libc cactsole cgoct userbins xfbdev
	@$(MAKE) -s -C "$(REPO)" -j$(JOBS) \
		CACTLIB_DIR="$(LIB)" \
		CACTSOLE_BIN="$(SOLE)/cactsole" \
		CGOCT_BIN="$(CGOCT)/cgoct" \
		XFBDEV_BIN="$(XFBDEV)/build/xfbdev" \
		USERBINS_MK="$(USERBINS)" \
		CACTSOLEINC="$(SOLE)/include" \
		LR_BIN="$(REPO)/lib/bin" \
		LR_SBIN="$(REPO)/lib/sbin"

kernel:
	@$(MAKE) -s -C "$(KERN)" -j$(JOBS) build/kernel.bin

iso:
	cd "$(ROOT)" && python3 "$(BRIDGE)/build.py" --non-gui-iso

GUI_REPO := $(ROOT)/LocalRepoCactOS-gui

gui-xfbdev: libc
	@$(MAKE) -s -C "$(XFBDEV)" -j$(JOBS) CACTLIB="$(LIB)"

cgoct-gui: libc
	@$(MAKE) -s -C "$(CGOCT_GUI)" -j$(JOBS) CACTLIB="$(LIB)"

gui-localrepo: drivers libc cgoct-gui gui-xfbdev
	@$(MAKE) -s -C "$(GUI_REPO)" -j$(JOBS) \
		CACTLIB_DIR="$(LIB)" \
		XFBDEV_BIN="$(XFBDEV)/build/xfbdev" \
		CGOCT_GUI_BIN="$(CGOCT_GUI)/cgoct-gui" \
		USERBINS_MK="$(USERBINS)" \
		LR_BIN="$(GUI_REPO)/lib/bin" \
		LR_SBIN="$(GUI_REPO)/lib/sbin"

iso-gui: kernel gui-localrepo
	cd "$(ROOT)" && python3 "$(BRIDGE)/build.py" --gui-iso --no-deps

disk: iso
	@"$(KERN)/build_disk.sh"

all: iso-gui

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
	@$(MAKE) -s -C "$(CGOCT_GUI)" clean
	@$(MAKE) -s -C "$(GUI_REPO)" clean
	@$(MAKE) -s -C "$(USERBINS)" clean
