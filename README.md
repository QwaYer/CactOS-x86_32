# 🌵 CactOS/x86_32

<p align="center">
  <img src="https://img.shields.io/badge/license-GPLv3-blue.svg?style=for-the-badge" alt="License: GPLv3">
  <img src="https://img.shields.io/badge/arch-i686-red.svg?style=for-the-badge" alt="Arch: i686">
  <img src="https://img.shields.io/badge/language-C%2FRust%2FASM-orange.svg?style=for-the-badge" alt="Language: C/Rust/ASM">
  <img src="https://img.shields.io/badge/role-workspace%20integrator-purple.svg?style=for-the-badge" alt="Role: workspace integrator">
  <img src="https://img.shields.io/badge/output-cact.iso-0369a1.svg?style=for-the-badge" alt="Output: cact.iso via CactBridge">
  <img src="https://img.shields.io/badge/status-2.0.0-yellow.svg?style=for-the-badge" alt="Status: 2.0.0">
</p>

<p align="center">
  <strong>Workspace integrator</strong> for <strong>CactOS</strong> — builds the full ISO from kernel, libc, drivers, shell, and userland.<br>
  One <code>ninja -C build-meson stage</code> drives <strong>CactLib</strong>, <strong>Cactsole</strong>, <strong>Cgoct</strong>, <strong>CactUserBins</strong>, out-of-tree <strong>*-for-Cact</strong> drivers, <strong>LocalRepoCactOS-x86_32</strong> (cctkfs.img) and <strong>CactKernel</strong>; <code>iso</code>/<code>iso-gui</code> then drive <strong>CactBridge</strong> (ISO).
</p>

<p align="center">
  <a href="https://github.com/QwaYer/CactKernel-x86_32"><strong>CactKernel</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactLibc-x86_32"><strong>CactLib</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/Cactsole-x86_32"><strong>Cactsole</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/Cgoct-x86_32"><strong>Cgoct</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactUserBins-x86_32"><strong>CactUserBins</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/LocalRepoCactOS-x86_32"><strong>LocalRepo</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactBridge-x86"><strong>CactBridge</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactXfbdev-x86_32"><strong>CactXfbdev</strong></a>
</p>

---

## 📊 Stats

| | |
|---|---|
| **Repositories integrated** | 10+ (kernel, libc, shell, init, userbins, drivers, packer, bridge, Xfbdev, GUI) |
| **Syscall traps** | 15 — authoritative enum in `CactKernel-x86_32` [`syscalls.h`](https://github.com/QwaYer/CactKernel-x86_32/blob/main/Cact/kernel/core/syscall/syscalls.h); every other operation is a VFS-node ioctl ([`ioctl_abi.h`](https://github.com/QwaYer/CactKernel-x86_32/blob/main/Cact/kernel/core/syscall/ioctl_abi.h)) |
| **Default goal** | `iso-gui` — full ISO with GUI support |
| **Drivers (out-of-tree)** | AHCI, NVMe, Virtio-net, Virtio-gpu, Yukon, Intel-HDA, Intel-GPU (PCI `.cctk`) + EXT4, FAT32 (filesystem `.cctk`) + RT2800USB (USB `.cctk`) — staged by the `drivers` target |
| **Kernel arch** | i686 (32-bit x86 protected mode) |
| **Boot** | Multiboot2 |

---

## 🔗 Ecosystem

| Component | Role |
|---|---|
| **[CactKernel-x86_32](https://github.com/QwaYer/CactKernel-x86_32)** | Hybrid monolithic kernel — C/Rust/ASM, MLFQ scheduler, PMM/VMM, TCP/IP |
| **[CactLib-x86_32](https://github.com/QwaYer/CactLibc-x86_32)** | Freestanding libc (`clibc.so` + `ld.so`) — `sysenter`/`sysexit` syscall gateway (AMD `syscall`/`sysret` fast path); TLS 1.3 client |
| **[Cactsole-x86_32](https://github.com/QwaYer/Cactsole-x86_32)** | Interactive shell — pipelines, redirections, job control, builtins |
| **[Cgoct-x86_32](https://github.com/QwaYer/Cgoct-x86_32)** | Ring-3 supervisor (`/usr/bin/init`) — respawns shell with crash-loop damping |
| **[CactUserBins-x86_32](https://github.com/QwaYer/CactUserBins-x86_32)** | 84 userspace tools — `ls`, `cat`, `ping`, `ip`, `wget`, etc. |
| **[CactXfbdev-x86_32](https://github.com/QwaYer/CactXfbdev-x86_32)** | Framebuffer compositor — GUI support on tty |
| **[CactBridge](https://github.com/QwaYer/CactBridge-x86)** | ISO packager — wraps kernel.bin + cctkfs.img via grub-mkrescue |
| **[LocalRepoCactOS-x86_32](../LocalRepoCactOS-x86_32)** | Staging tree → `cctkfs.img` — PCI drivers + user ELFs in one Multiboot2 module |
| **[Cgoct-gui-x86_32](https://github.com/QwaYer/Cgoct-gui-x86_32)** | GUI supervisor variant |
| **[LocalRepoCactOS-gui](../LocalRepoCactOS-gui)** | GUI cctkfs staging tree |

**`*-for-Cact` driver repos** (out-of-tree kernel modules packaged as `.cctk`):

| Driver | Bus | Output |
|---|---|---|
| **[AHCI-for-Cact](https://github.com/QwaYer/AHCI-for-Cact-x86_32)** | SATA HBA | `ahci.cctk` |
| **[NVMe-for-Cact](https://github.com/QwaYer/NVMe-for-Cact-x86_32)** | NVMe | `nvme.cctk` |
| **[Virtio-net-for-Cact](https://github.com/QwaYer/Virtio-net-for-Cact-x86_32)** | virtio NIC | `virtio_net.cctk` |
| **[Virtio-gpu-for-Cact](https://github.com/QwaYer/Virtio-gpu-for-Cact-x86_32)** | virtio GPU | `virtio_gpu.cctk` |
| **[Yukon-for-Cact](https://github.com/QwaYer/Yukon-for-Cact-x86_32)** | Yukon Ethernet | `yukon.cctk` |
| **[Intel-HDA-for-Cact](https://github.com/QwaYer/Intel-HDA-for-Cact-x86_32)** | HD Audio | `hda_audio.cctk` |
| **[Intel-GPU-for-Cact](https://github.com/QwaYer/Intel-GPU-for-Cact-x86_32)** | Intel i915 graphics | `i915.cctk` |
| **[EXT4-for-Cact](https://github.com/QwaYer/EXT4-for-Cact-x86_32)** | ext4 filesystem (`fs_mod`) | `ext4.cctk` |
| **[FAT32-for-Cact](https://github.com/QwaYer/FAT32-for-Cact-x86_32)** | FAT32 filesystem (`fs_mod`) | `fat32.cctk` |
| **[RT2800USB-for-Cact](https://github.com/QwaYer/RT2800USB-for-Cact-x86_32)** | Ralink RT2800 USB Wi-Fi (`usb_mod`) | `rt2800usb.cctk` |

---

## 🔨 Building

**Quick start — full ISO + QEMU:**

```sh
./build-cact-qemu.sh           # full ISO + disk, 1 command
RUN_QEMU=1 ./build-cact-qemu.sh  # build + run
```

**From this directory (Meson + Ninja):**

```sh
meson setup build-meson
ninja -C build-meson stage    # libc → cactsole/cgoct → userbins → drivers → cctkfs.img
ninja -C build-meson kernel   # kernel.bin only
ninja -C build-meson iso      # non-GUI ISO via CactBridge build.py --non-gui-iso
ninja -C build-meson iso-gui  # GUI ISO via CactBridge build.py --gui-iso
ninja -C build-meson disk     # empty ext4 CactKernel-x86_32/build/nvme.img
```

| Target | What you get |
|---|---|
| `ninja -C build-meson stage` | **libc** → **cactsole/cgoct** → **userbins** → **drivers** → **LocalRepoCactOS-x86_32** (`cctkfs.img`) → **kernel.bin** |
| `ninja -C build-meson iso` | **kernel** → **localrepo** → **ISO via CactBridge `build.py --non-gui-iso`** |
| `ninja -C build-meson iso-gui` | Same, through **`build.py --gui-iso`** |
| `ninja -C build-meson disk` | empty **ext4** `CactKernel-x86_32/build/nvme.img` |
| `ninja -C build-meson kernel` | Kernel only |
| `ninja -C build-meson drivers` | Out-of-tree **`*-for-Cact-x86_32`** modules only |
| `ninja -C build-meson libc`, `… userbins`, `… localrepo`, … | Fine-grained steps |
| `ninja -C build-meson distclean` | Clean every sibling build directory |

Meson reserves the target names `install`/`test`/`clean`, hence **`stage`** and **`distclean`**.

### Component map (how the chain flows)

```
ninja stage ─ libc ─────► CactLibc-x86_32 (clibc.so / ld.so / start.o)
              cactsole ─► Cactsole-x86_32 (depends on libc)
              cgoct ────► Cgoct-x86_32 (depends on libc)
              userbins ─► CactUserBins-x86_32 (depends on libc + cactsole includes)
              drivers ──► *-for-Cact-x86_32 modules → *.cctk into LocalRepoCactOS-x86_32/lib/
              localrepo ► LocalRepoCactOS-x86_32 → cctkfs.img (all userland + modules)
ninja kernel ───────────► CactKernel-x86_32 → build-meson/kernel.bin
ninja iso ──────────────► CactBridge-x86 build.py → cact-non-gui.iso
ninja iso-gui ──────────► CactBridge-x86 build.py --gui-iso
```

### Build individual components (standalone)

Each component is its own Meson project with sensible sibling defaults:

```sh
meson setup CactLibc-x86_32/build-meson --cross-file CactLibc-x86_32/cross/i686-cact-clang.ini
ninja -C CactLibc-x86_32/build-meson             # libc (no deps)
ninja -C Cactsole-x86_32/build-meson             # shell (auto-finds ../CactLibc-x86_32)
ninja -C Cgoct-x86_32/build-meson                # init/supervisor (auto-finds ../CactLibc-x86_32)
ninja -C CactUserBins-x86_32/build-meson stage   # userland utils → LocalRepo
ninja -C CactKernel-x86_32/build-meson           # kernel only
ninja -C AHCI-for-Cact-x86_32/build-meson stage  # AHCI driver → LocalRepoCactOS-x86_32/lib/
ninja -C LocalRepoCactOS-x86_32/build-meson stage # pack cctkfs.img
python3 CactBridge-x86/build.py --non-gui-iso    # ISO from kernel.bin + cctkfs.img
```

Siblings that have never been configured are set up automatically when driven
through this repo's targets.

**QEMU:** set **`CACT_ISO`** to the ISO path and run `CactKernel-x86_32/run_qemu.sh`.

---

## 📂 Repository layout (this repo)

```
CactOS-x86_32/
├── meson.build    # orchestrates all sibling repos
├── LICENSE        # GPLv3
└── README.md
```

This repo contains no source code — it is the **build conductor** that drives `ninja` in sibling build directories. All actual code lives in the repos listed above.

### Sibling tree expected by `meson.build`

```
parent/
├── CactOS-x86_32           ← you are here
├── CactKernel-x86_32       ← hybrid kernel
├── CactLib-x86_32          ← freestanding libc
├── Cactsole-x86_32         ← interactive shell
├── Cgoct-x86_32            ← /usr/bin/init (supervisor)
├── Cgoct-gui-x86_32        ← GUI supervisor
├── CactUserBins-x86_32     ← 84 userspace tools
├── CactXfbdev-x86_32       ← framebuffer compositor
├── LocalRepoCactOS-x86_32  ← cctkfs.img packer (non-GUI)
├── LocalRepoCactOS-gui     ← cctkfs.img packer (GUI)
├── CactBridge-x86          ← ISO packager
├── AHCI-for-Cact-x86_32    ← AHCI driver module
├── NVMe-for-Cact-x86_32    ← NVMe driver module
├── Virtio-net-for-Cact-x86_32 ← virtio-net driver module
├── Virtio-gpu-for-Cact-x86_32 ← virtio-gpu driver module
├── Yukon-for-Cact-x86_32   ← Yukon NIC driver module
├── Intel-HDA-for-Cact-x86_32 ← HD Audio driver module
├── Intel-GPU-for-Cact-x86_32 ← Intel i915 graphics module
├── EXT4-for-Cact-x86_32    ← ext4 filesystem module
├── FAT32-for-Cact-x86_32   ← FAT32 filesystem module
├── RT2800USB-for-Cact-x86_32 ← Ralink RT2800 USB Wi-Fi module
└── build-cact-qemu.sh      ← convenience one-shot script
```

---

## 🚀 Typical boot flow

Build: `ninja -C build-meson iso-gui` produces `CactBridge-x86/build/cact-gui.iso`. Boot sequence:

1. **GRUB** (Multiboot2) loads `kernel.bin` + `cctkfs.img` module
2. **CactKernel** initialises: PMM/VMM → slab → I/O APIC + IDT → PCI → xHCI → page cache → VFS → network → scheduler
3. Kernel launches **`/usr/bin/init`** — this is **cgoct** (or **cgoct-gui** for GUI builds)
4. **cgoct** spawns **cactsole** (interactive shell)
5. User has **84 tools** via **CactUserBins** on `PATH=/usr/bin:/usr/sbin`

**Console banner:**

```
Cact Kernel 2.0.0
--------------------------
[VER] commit=…  built=…
Kernel is ready. Launching init…

cgoct: supervisor online
  restart policy : always
  rescue shell   : enabled
  crash limit    : 4
  cooldown       : 8 sec

cact:/$
```

---

## 💾 Drivers (out-of-tree)

Out-of-tree PCI drivers are compiled as relocatable `.cctk` ELFs and loaded by the kernel's `pci_load_module()` at runtime from the **cctkfs** archive.

| Driver | Kernel name | Manifest binding | IRQ |
|---|---|---|---|
| AHCI | SATA HBA | class 0x010601 | MSI-X / MSI |
| NVMe | NVM Express | class 0x010802 | MSI-X / MSI |
| Virtio-net | virtio NIC | vendor 0x1AF4, device 0x1000 / 0x1041 | MSI-X / MSI |
| Virtio-gpu | virtio GPU | vendor 0x1AF4, device 0x1050 | MSI-X / MSI |
| Yukon | Marvell Yukon | vendor 0x11AB, device 0x4354 | poll-only |
| Intel-HDA | HD Audio | class 0x040300 | MSI-X / MSI |
| i915 | Intel UHD Graphics | vendor 0x8086, devices 0x3E90–0x3E9B | MSI-X / MSI |

EXT4 and FAT32 are filesystem modules (`fs_mod`) and RT2800USB is a USB module (`usb_mod`), not PCI devices; they are staged through the same `drivers` list. Every out-of-tree PCI driver that takes interrupts registers through the kernel's **`msidev_register()`** (MSI-X when the device offers it, otherwise MSI), replacing the old PIC IRQ lines; the Yukon NIC is poll-only. Kernel syscall dispatch uses **`sysenter`/`sysexit`** with an AMD **`syscall`/`sysret`** fast path; the legacy `int 0x80` path has been removed.

---

## 📞 System calls (15 traps + VFS ioctls)

The kernel traps for exactly **15** syscalls; everything else is a **VFS-node service** reached through `ioctl` on the node. Authoritative lists: [`syscalls.h`](https://github.com/QwaYer/CactKernel-x86_32/blob/main/Cact/kernel/core/syscall/syscalls.h) (traps) and [`ioctl_abi.h`](https://github.com/QwaYer/CactKernel-x86_32/blob/main/Cact/kernel/core/syscall/ioctl_abi.h) (commands and structs) — both must stay byte-for-byte in sync with **[CactLib `syscall.h`](https://github.com/QwaYer/CactLibc-x86_32/blob/main/include/syscall.h)**.

| Group | Via | Operations |
|---|---|---|
| **Core traps** | `sysenter` | `open` `close` `read` `write` `ioctl` `poll` `fork` `exec` `exit` `waitpid` `brk` `mmap` `munmap` `mprotect` `sigreturn` |
| **Debug** | write to `/dev/console` | `kprint` |
| **FD / IO** | `CACT_FDCTL_*` (0x3000) | `dup` `dup2` `fcntl` `lseek` `fstat` `ftruncate` `getdents` `fsync` |
| **Paths / metadata** | `CACT_DIRCTL_*` (0x3100) | `openat` `create` `mkdir` `rmdir` `unlink` `link` `symlink` `readlink` `rename` `stat` `access` `chmod` `chown` `truncate` `mknod` |
| **Process / session / signals / SHM** | `CACT_PROCCTL_*` (0x3200) | `setsid` `setpgid` `getpgid` `setuid` `setgid` `umask` `chdir` `chroot` `kill` `sigaction` `sigprocmask` `alarm` `setitimer` `shmget` `shmat` `shmdt` `shmctl` |
| **Sockets** | `CACT_SOCKCTL_*` (0x3300) | `bind` `connect` `listen` `accept` `shutdown` `setsockopt` `getsockopt` `sendto` `recvfrom` `getsockname` `getpeername` (data via `read`/`write`) |
| **Network** | `CACT_NETCTL_*` (0x3400) on `/dev/net` | socket creation, `ping` / `ping_wait`, `dns_resolve`, `netcfg` / `netcfg_get`, `socketpair` |
| **System** | `CACT_SYSCTL_*` (0x3500) on `/dev/sys` | `mount` `umount` `reboot`, kernel module load/unload |
| **Pipes** | `CACT_PIPECTL_*` (0x3600) on `/dev/pipe` | `pipe` |
| **Crypto** | `CACT_CRYPTCTL_*` (0x3700) on `/dev/crypto` | `random`, hash/HMAC/HKDF, AES-GCM, X25519/P-256, `sig_verify`, `x509_verify` |
| **TTY / PTY** | `CACT_TTYCTL_*` (0x3D00) / `CACT_PTYCTL_*` (0x3E00) | VT activate/state, controlling tty, pts number/lock |
| **Info** | `/proc/*` | pid/ppid and friends via `/proc/self/info`; time via `/proc/time` and `/proc/wallclock`; `uname` via `/proc/uname` |

---

## ⚖️ License

**GNU General Public License v3.0** — see [`LICENSE`](LICENSE).

---

<p align="center">
  <strong>Developer:</strong> <a href="https://github.com/QwaYer">QwaYer</a>
  &nbsp;·&nbsp; <strong>Kernel:</strong> <a href="https://github.com/QwaYer/CactKernel-x86_32">CactKernel-x86_32</a>
  &nbsp;·&nbsp; <strong>Libc:</strong> <a href="https://github.com/QwaYer/CactLibc-x86_32">CactLib-x86_32</a>
</p>
