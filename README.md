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
  One <code>make</code> drives <strong>CactLib</strong>, <strong>Cactsole</strong>, <strong>Cgoct</strong>, <strong>CactUserBins</strong>, out-of-tree <strong>*-for-Cact</strong> drivers, <strong>LocalRepoCactOS</strong> (cctkfs.img), <strong>CactKernel</strong>, and <strong>CactBridge</strong> (ISO).
</p>

<p align="center">
  <a href="https://github.com/QwaYer/CactKernel-x86_32"><strong>CactKernel</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactLib-x86_32"><strong>CactLib</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/Cactsole-x86_32"><strong>Cactsole</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/Cgoct-x86_32"><strong>Cgoct</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactUserBins-x86_32"><strong>CactUserBins</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/LocalRepoCactOS"><strong>LocalRepo</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactBridge"><strong>CactBridge</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/QwaYer/CactXfbdev-x86_32"><strong>CactXfbdev</strong></a>
</p>

---

## 📊 Stats

| | |
|---|---|
| **Repositories integrated** | 10+ (kernel, libc, shell, init, userbins, drivers, packer, bridge, Xfbdev, GUI) |
| **Syscalls** | 95 — authoritative enum in `CactKernel-x86_32` [`syscalls.h`](https://github.com/QwaYer/CactKernel-x86_32/blob/main/Cact/kernel/core/syscalls/syscalls.h) |
| **Default goal** | `iso-gui` — full ISO with GUI support |
| **Drivers (out-of-tree)** | AHCI, NVMe, Virtio-net, Yukon (opt-in via `DRIVERS` variable) |
| **Kernel arch** | i686 (32-bit x86 protected mode) |
| **Boot** | Multiboot2 |

---

## 🔗 Ecosystem

| Component | Role |
|---|---|
| **[CactKernel-x86_32](https://github.com/QwaYer/CactKernel-x86_32)** | Hybrid monolithic kernel — C/Rust/ASM, MLFQ scheduler, PMM/VMM, TCP/IP |
| **[CactLib-x86_32](https://github.com/QwaYer/CactLib-x86_32)** | Freestanding libc (`libc.a` / `libc.so`) — `int 0x80` syscall gateway |
| **[Cactsole-x86_32](https://github.com/QwaYer/Cactsole-x86_32)** | Interactive shell — pipelines, redirections, job control, builtins |
| **[Cgoct-x86_32](https://github.com/QwaYer/Cgoct-x86_32)** | Ring-3 supervisor (`/bin/init`) — respawns shell with crash-loop damping |
| **[CactUserBins-x86_32](https://github.com/QwaYer/CactUserBins-x86_32)** | 36 userspace ELFs — `ls`, `cat`, `ping`, `dhcp`, `dns`, etc. |
| **[CactXfbdev-x86_32](https://github.com/QwaYer/CactXfbdev-x86_32)** | Framebuffer compositor — GUI support on tty |
| **[CactBridge](https://github.com/QwaYer/CactBridge)** | ISO packager — wraps kernel.bin + cctkfs.img via grub-mkrescue |
| **[LocalRepoCactOS](../LocalRepoCactOS)** | Staging tree → `cctkfs.img` — PCI drivers + user ELFs in one Multiboot2 module |
| **[Cgoct-gui-x86_32](https://github.com/QwaYer/Cgoct-gui-x86_32)** | GUI supervisor variant |
| **[LocalRepoCactOS-gui](../LocalRepoCactOS-gui)** | GUI cctkfs staging tree |

**`*-for-Cact` driver repos** (out-of-tree PCI modules packaged as `.cctk`):

| Driver | Bus | Output |
|---|---|---|
| **[AHCI-for-Cact](https://github.com/QwaYer/AHCI-for-Cact)** | SATA HBA | `ahci.cctk` |
| **[NVMe-for-Cact](https://github.com/QwaYer/NVMe-for-Cact)** | NVMe | `nvme.cctk` |
| **[Virtio-net-for-Cact](https://github.com/QwaYer/Virtio-net-for-Cact)** | virtio NIC | `virtio_net.cctk` |
| **[Yukon-for-Cact](https://github.com/QwaYer/Yukon-for-Cact)** | Yukon Ethernet | `yukon.cctk` |

---

## 🔨 Building

**Quick start — full ISO + QEMU:**

```sh
./build-cact-qemu.sh           # full ISO + disk, 1 command
RUN_QEMU=1 ./build-cact-qemu.sh  # build + run
```

**From this directory:**

```sh
make -j$(nproc)               # default: iso-gui (kernel + GUI localrepo + ISO)
make iso                      # non-GUI ISO (kernel + localrepo + ISO)
make disk                     # iso + empty ext4 nvme.img
make kernel                   # kernel only
make libc                     # libc only
make cactsole                 # shell only
make drivers                  # all out-of-tree drivers only
```

| Target | What you get |
|---|---|
| `make` / `make all` / `make iso-gui` | **kernel** → **gui-localrepo** (cgoct-gui + xfbdev + drivers) → **ISO via CactBridge `build.py --gui-iso`** |
| `make iso` | **kernel** → **localrepo** (libc + cactsole + cgoct + xfbdev + userbins + drivers) → **ISO via CactBridge `build.py --non-gui-iso`** |
| `make disk` | **iso** + empty **ext4** `CactKernel-x86_32/build/nvme.img` |
| `make kernel` | Kernel only |
| `make drivers` | Out-of-tree **`*-for-Cact`** modules only |
| `make libc`, `make localrepo`, … | Fine-grained steps (see [`Makefile`](Makefile)) |

Optional: `SKIP_DRIVERS=1`, `DRIVERS="AHCI NVMe Virtio-net Yukon"`, `JOBS=N`.

### Component map (how `make` flows)

```
make libc ──────────► CactLib-x86_32 (libc.a / libc.so)
make cactsole ──────► Cactsole-x86_32 (depends on libc)
make cgoct ─────────► Cgoct-x86_32 (depends on libc)
make userbins ──────► CactUserBins-x86_32 (depends on libc + cactsole includes)
make xfbdev ────────► CactXfbdev-x86_32 (depends on libc)
make drivers ───────► *-for-Cact repos → *.cctk into LocalRepoCactOS/lib/
make localrepo ─────► LocalRepoCactOS → cctkfs.img (all userland + drivers)
make kernel ────────► CactKernel-x86_32 → kernel.bin
make iso ───────────► CactBridge build.py → cact.iso (kernel.bin + cctkfs.img)
make iso-gui ───────► gui-localrepo → kernel → CactBridge build.py --gui-iso
```

### Build individual components (standalone)

Each component auto-detects sibling directories:

```sh
make -C CactLib-x86_32               # libc (no deps)
make -C Cactsole-x86_32              # shell (auto-finds ../CactLib-x86_32)
make -C Cgoct-x86_32                 # init (auto-finds ../CactLib-x86_32)
make -C CactXfbdev-x86_32            # framebuffer compositor (auto-finds ../CactLib-x86_32)
make -C CactUserBins-x86_32 install  # userland utils
make -C CactKernel-x86_32            # kernel only
make -C AHCI-for-Cact install        # AHCI driver → LocalRepoCactOS/lib/
make -C LocalRepoCactOS              # pack cctkfs.img
make -C CactBridge iso               # ISO from kernel.bin + cctkfs.img
```

**QEMU:** set **`CACT_ISO`** to the ISO path and run `CactKernel-x86_32/run_qemu.sh`.

---

## 📂 Repository layout (this repo)

```
CactOS-x86_32/
├── Makefile       # orchestrates all sibling repos
├── LICENSE        # GPLv3
└── README.md
```

This repo contains no source code — it is the **build conductor** that invokes `make` in sibling directories. All actual code lives in the repos listed above.

### Sibling tree expected by `Makefile`

```
parent/
├── CactOS-x86_32           ← you are here
├── CactKernel-x86_32       ← hybrid kernel
├── CactLib-x86_32          ← freestanding libc
├── Cactsole-x86_32         ← interactive shell
├── Cgoct-x86_32            ← /bin/init (supervisor)
├── Cgoct-gui-x86_32        ← GUI supervisor
├── CactUserBins-x86_32     ← 36 userspace tools
├── CactXfbdev-x86_32       ← framebuffer compositor
├── LocalRepoCactOS         ← cctkfs.img packer (non-GUI)
├── LocalRepoCactOS-gui     ← cctkfs.img packer (GUI)
├── CactBridge              ← ISO packager
├── AHCI-for-Cact           ← AHCI driver module
├── NVMe-for-Cact           ← NVMe driver module
├── Virtio-net-for-Cact     ← virtio-net driver module
├── Yukon-for-Cact          ← Yukon NIC driver module
└── build-cact-qemu.sh      ← convenience one-shot script
```

---

## 🚀 Typical boot flow

Build: `make iso-gui` produces `CactBridge/build/cact.iso`. Boot sequence:

1. **GRUB** (Multiboot2) loads `kernel.bin` + `cctkfs.img` module
2. **CactKernel** initialises: PMM/VMM → slab → PIC/IDT → PS/2 → PCI → xHCI → page cache → VFS → network → scheduler
3. Kernel launches **`/bin/init`** — this is **cgoct** (or **cgoct-gui** for GUI builds)
4. **cgoct** spawns **cactsole** (interactive shell)
5. User has **36 tools** via **CactUserBins** on `PATH=/bin:/sbin`

**Console banner:**

```
Cact Kernel 1.0.0
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

| Driver | Kernel name | PCI class | MSI-X |
|---|---|---|---|
| AHCI | SATA HBA | 0x010601 | Yes |
| NVMe | NVM Express | 0x010802 | Yes |
| Virtio-net | virtio NIC | 0x020000 (Virtio) | Yes |
| Yukon | Marvell Yukon | 0x020000 | Yes |

All out-of-tree drivers have been migrated from PIC-based IRQ to **MSI-X** for better performance and scalability. Kernel syscall dispatch uses **`sysenter`** (legacy `int 0x80` removed).

---

## 📞 System calls (95 total)

Authoritative list: [`CactKernel-x86_32/syscalls.h`](https://github.com/QwaYer/CactKernel-x86_32/blob/main/Cact/kernel/core/syscalls/syscalls.h) — must stay byte-for-byte in sync with **[CactLib `syscall.h`](https://github.com/QwaYer/CactLib-x86_32/blob/main/include/syscall.h)**.

| Group | Calls |
|---|---|
| **Debug** | `print` |
| **Process** | `getpid` `getppid` `fork` `exec` `exit` `waitpid` `sleep` |
| **Session** | `setsid` `setpgid` `getpgid` `getpgrp` |
| **Signals** | `kill` `signal` `sigaction` `sigprocmask` `sigreturn` `sigpending` `sigsuspend` `alarm` `setitimer` |
| **FD / IO** | `open` `read` `write` `close` `lseek` `ioctl` `fcntl` `dup` `dup2` `pipe` `select` `poll` |
| **File metadata** | `stat` `fstat` `access` `chmod` `chown` `umask` `truncate` `ftruncate` `sync` `fsync` `mknod` |
| **Paths** | `create` `mkdir` `rmdir` `delete` `unlink` `rename` `link` `symlink` `readlink` `getdents` `chdir` `getcwd` `chroot` |
| **System** | `mount` `umount` `reboot` `uname` |
| **Memory** | `brk` `mmap` `munmap` `mprotect` |
| **SHM** | `shmget` `shmat` `shmdt` `shmctl` |
| **Time** | `gettimeofday` `clock_gettime` `nanosleep` |
| **Users** | `getuid` `getgid` `geteuid` `getegid` `setuid` `setgid` |
| **Network** | `socket` `bind` `connect` `listen` `accept` `send` `recv` `sendto` `recvfrom` `shutdown` `setsockopt` `getsockopt` plus **`SYS_PING_ECHO` (90)**, **`SYS_NETCFG_SET` (91)**, **`SYS_DNS_RESOLVE` (94)** |
| **Kernel modules** | `module_load` (92) `module_unload` (93) |

---

## ⚖️ License

**GNU General Public License v3.0** — see [`LICENSE`](LICENSE).

---

<p align="center">
  <strong>Developer:</strong> <a href="https://github.com/QwaYer">QwaYer</a>
  &nbsp;·&nbsp; <strong>Kernel:</strong> <a href="https://github.com/QwaYer/CactKernel-x86_32">CactKernel-x86_32</a>
  &nbsp;·&nbsp; <strong>Libc:</strong> <a href="https://github.com/QwaYer/CactLib-x86_32">CactLib-x86_32</a>
</p>
