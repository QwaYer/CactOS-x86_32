# 🌵 CactOS/x86_32

<p align="center">
  <a href="https://github.com/CactKernelProject/CactOS/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-GPLv3-blue.svg?style=for-the-badge" alt="License: GPLv3">
  </a>
  <img src="https://img.shields.io/badge/arch-i686-red.svg?style=for-the-badge" alt="Arch: i686">
  <img src="https://img.shields.io/badge/language-C%2FRust-orange.svg?style=for-the-badge" alt="Language: C/Rust">
  <img src="https://img.shields.io/badge/role-workspace%20integrator-purple.svg?style=for-the-badge" alt="Role: workspace integrator">
  <img src="https://img.shields.io/badge/output-cact.iso-green.svg?style=for-the-badge" alt="Output: cact.iso via CactBridge">
  <img src="https://img.shields.io/badge/status--1.0.0-yellow.svg?style=for-the-badge" alt="Status: 1.0.0">
</p>

<p align="center">
  <strong>English.</strong> Monolithic OS (with microkernel-style pieces) for <strong>i686</strong>: low level in <strong>C</strong>, critical subsystems in <strong>Rust</strong>.<br>
  <strong>Русский.</strong> Монолитная ОС для <strong>i686</strong>: низкий уровень на <strong>C</strong>, память / планировщик / синхронизация на <strong>Rust</strong>.
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
</p>

---

## 📑 Contents

| | |
| --- | --- |
| 🏗️ | [Building the workspace](#building-the-workspace) |
| 🇬🇧 | [English: technical specifications](#english-technical-specifications) |
| 🇷🇺 | [Русский: технические характеристики](#russian-technical-specifications) |
| 🗺️ | [Architecture visualization](#architecture-visualization) |
| 🙏 | [Credits and license](#credits-and-license) |

---

<a id="building-the-workspace"></a>

## 🏗️ Building the workspace

### 🇬🇧 English — Quick Start

```sh
./build-cact-qemu.sh           # full ISO + disk, 1 command
./build-cact-qemu.sh && CACT_ISO=CactBridge/build/cact.iso CactKernel-x86_32/run_qemu.sh
RUN_QEMU=1 ./build-cact-qemu.sh  # build + run
```

**Or step by step from this directory:**

```sh
make -j$(nproc)               # full ISO  (default)
make -j$(nproc) disk          # ISO + empty nvme.img
make -j$(nproc) kernel        # kernel only
make -j$(nproc) libc          # libc only
make -j$(nproc) cactsole      # shell only
make -j$(nproc) drivers       # all out-of-tree drivers only
```

| Target | What you get |
| --- | --- |
| `make` / `make all` / `make iso` | **libc** → **cactsole** / **cgoct** → **CactUserBins** `install` → **`*.cctk`** → **`cctkfs.img`** → **kernel** → **`CactBridge/build/cact.iso`** |
| `make disk` | **iso** + empty **ext4** `CactKernel-x86_32/build/nvme.img` |
| `make kernel` | Kernel only |
| `make drivers` | Out-of-tree **`*-for-Cact`** modules only |
| `make libc`, `make localrepo`, … | Fine-grained steps (see [`Makefile`](Makefile)) |

Optional: `SKIP_DRIVERS=1`, `DRIVERS="AHCI NVMe Virtio-net Yukon"`, `JOBS=N`.

### Build individual components (standalone)

Each component auto-detects sibling directories. Just run `make` from its directory:

```sh
make -C CactLib-x86_32               # libc (no deps)
make -C Cactsole-x86_32              # shell  (auto-finds ../CactLib-x86_32)
make -C Cgoct-x86_32                 # init   (auto-finds ../CactLib-x86_32)
make -C CactUserBins-x86_32 install  # userland utils (auto-finds all deps)
make -C CactKernel-x86_32            # kernel only ISO
make -C CactKernel-x86_32 iso-full   # kernel + userland ISO
make -C AHCI-for-Cact install        # AHCI driver → LocalRepoCactOS/lib/
make -C NVMe-for-Cact install        # NVMe driver
make -C Virtio-net-for-Cact install  # virtio-net driver
make -C Yukon-for-Cact install       # Yukon NIC driver
make -C LocalRepoCactOS              # pack cctkfs.img (auto-finds all deps)
make -C CactBridge iso               # ISO from kernel.bin + cctkfs.img
```

Override any path if needed: `make -C CactKernel-x86_32 LOCAL_REPO=/other/path`.

**QEMU:** set **`CACT_ISO`** to the ISO path and run `CactKernel-x86_32/run_qemu.sh`.

### 🇷🇺 Русский — Быстрый старт

```sh
./build-cact-qemu.sh           # полный ISO + диск, 1 команда
RUN_QEMU=1 ./build-cact-qemu.sh  # собрать + запустить
```

**Или по шагам из этого каталога:**

```sh
make -j$(nproc)               # полный ISO
make -j$(nproc) disk          # ISO + пустой nvme.img
make -j$(nproc) kernel        # только ядро
make -j$(nproc) cactsole      # только оболочка
```

Переменные: `SKIP_DRIVERS=1`, `DRIVERS=…`, `JOBS=N`.

### Сборка отдельных компонентов

Каждый компонент автоопределяет соседей. Достаточно `make` из его каталога:

```sh
make -C CactLib-x86_32               # libc
make -C Cactsole-x86_32              # оболочка
make -C Cgoct-x86_32                 # init
make -C CactUserBins-x86_32 install  # утилиты
make -C CactKernel-x86_32            # ядро (ISO без userland)
make -C CactKernel-x86_32 iso-full   # ядро с userland
make -C AHCI-for-Cact install        # драйвер AHCI
make -C LocalRepoCactOS              # упаковка cctkfs.img
make -C CactBridge iso               # ISO из kernel.bin + cctkfs.img
```

**QEMU:** переменная **`CACT_ISO`**, либо **`cact.iso`** в **`build/`** ядра.

---

<a id="english-technical-specifications"></a>

## 🇬🇧 English: technical specifications (pre-1.0)

### 🧠 Boot and core kernel

- **Multiboot2** parser (framebuffer, memory map).
- **GDT** (ring 0/3), **TSS** for stack switches.
- **IDT**: 32 CPU exception ISRs, PIC (8259A), PIT 100 Hz.
- **Kernel panic** with register dump.
- **Exception → signal** (#DE/#MF → SIGFPE, #GP → SIGSEGV, else SIGKILL).
- **Versioning**: `VERSION`, git hash, build time.

### 🧠 Memory manager (Rust, `rust_mm`)

- **PMM** / **VMM** / **heap** / **slab** / **mmap** / **COW** / **swap** / **page faults** / **OOM** / **shm**.

### ⏱️ Scheduler (Rust, `sched`)

- **MLFQ**, priority boost, sleep queue, timer wheel.

### 🔒 Synchronization (Rust)

- **Spinlock**, **IRQ spinlock**, **mutex**, **semaphore**.

### 🧬 Processes and signals

- **TaskStruct**, **fork** / **exec** / **exit** / **waitpid**, 13 signals, `sigaction`, `int 0x80` user return.

### 📦 ELF and dynamic linking

- **ELF loader**, **dynamic linker**, i386 relocations including **`R_386_COPY`**.

### 📁 VFS and filesystems

- **VFS**, **ext4**, **devfs**, **procfs**, **mntfs**, **etcfs**, **pipes**, minimal FS stubs.

### 💾 Block I/O and drivers

- **PCI**, **AHCI**, **NVMe**, caches, **xHCI**, **USB**, **PS/2**, **virtio-net**, **framebuffer**.

### 🌐 Network stack

- **skb** → Ethernet → ARP → IPv4 → ICMP / UDP / **TCP**, sockets, **knetd**, static IP.

### 📞 System calls (73)

| Group | Syscalls |
| --- | --- |
| Files | `open`, `read`, `write`, `close`, `create`, `delete`, `lseek`, `stat`, `fstat`, `getdents`, `rename`, `mkdir`, `rmdir`, `fcntl`, `ioctl`, `symlink`, `readlink`, `link`, `unlink` |
| Processes | `fork`, `exec`, `exit`, `kill`, `signal`, `sigaction`, `sigreturn`, `sigprocmask`, `sigpending`, `sigsuspend`, `getpid`, `getppid`, `waitpid`, `sleep`, `brk`, `alarm`, `setitimer` |
| Memory | `mmap`, `munmap`, `mprotect`, `shmget`, `shmat`, `shmdt`, `shmctl` |
| Network | `socket`, `bind`, `connect`, `listen`, `accept`, `send`, `recv`, `sendto`, `recvfrom`, `shutdown`, `setsockopt`, `getsockopt`, `select`, `poll` |
| I/O | `pipe`, `dup2`, `getcwd`, `chdir` |
| Users | `getuid`, `getgid`, `setuid`, `setgid`, `geteuid`, `getegid`, `chmod`, `chown` |
| Time | `gettimeofday`, `clock_gettime`, `nanosleep` |
| Misc | `print` |

---

<a id="russian-technical-specifications"></a>

## 🇷🇺 Русский: технические характеристики (pre-1.0)

### 🧠 Загрузка и ядро

- **Multiboot2**, **GDT** / **TSS**, **IDT**, panic, исключения → сигналы, версия в бинарнике.

### 🧠 Менеджер памяти (Rust, `rust_mm`)

- **PMM**, **VMM**, **heap**, **slab**, **mmap**, **COW**, **swap**, fault, **OOM**, **shm**.

### ⏱️ Планировщик (Rust, `sched`)

- **MLFQ**, boost, sleep, timer wheel.

### 🔒 Синхронизация (Rust)

- **Spinlock**, **IRQ spinlock**, **mutex**, **semaphore**.

### 🧬 Процессы и сигналы

- **TaskStruct**, **fork** / **exec** / **exit** / **waitpid**, сигналы, маски, таймеры.

### 📦 ELF и динамическая линковка

- Загрузчик **ELF**, динлинкер, релокации.

### 📁 VFS и файловые системы

- **VFS**, **ext4**, **devfs**, **procfs**, **mntfs**, **etcfs**, **pipes**, заглушки.

### 💾 Блочный ввод-вывод и драйверы

- **PCI**, **AHCI**, **NVMe**, кеши, **USB**, **PS/2**, **virtio-net**, **framebuffer**.

### 🌐 Сетевой стек

- Полный стек до **TCP**, сокеты, **knetd**, статический IP.

### 📞 Системные вызовы (73)

| Группа | Вызовы |
| --- | --- |
| Файлы | `open`, `read`, `write`, `close`, `create`, `delete`, `lseek`, `stat`, `fstat`, `getdents`, `rename`, `mkdir`, `rmdir`, `fcntl`, `ioctl`, `symlink`, `readlink`, `link`, `unlink` |
| Процессы | `fork`, `exec`, `exit`, `kill`, `signal`, `sigaction`, `sigreturn`, `sigprocmask`, `sigpending`, `sigsuspend`, `getpid`, `getppid`, `waitpid`, `sleep`, `brk`, `alarm`, `setitimer` |
| Память | `mmap`, `munmap`, `mprotect`, `shmget`, `shmat`, `shmdt`, `shmctl` |
| Сеть | `socket`, `bind`, `connect`, `listen`, `accept`, `send`, `recv`, `sendto`, `recvfrom`, `shutdown`, `setsockopt`, `getsockopt`, `select`, `poll` |
| Ввод-вывод | `pipe`, `dup2`, `getcwd`, `chdir` |
| Пользователи | `getuid`, `getgid`, `setuid`, `setgid`, `geteuid`, `getegid`, `chmod`, `chown` |
| Время | `gettimeofday`, `clock_gettime`, `nanosleep` |
| Прочее | `print` |

---

<a id="architecture-visualization"></a>

## 🗺️ Architecture visualization

### 🇬🇧 English

**React**-based map of memory, drivers, and networking: [open the architecture map](https://htmlpreview.github.io/?https://github.com/CactKernelProject/CactOS/blob/main/docs/architecture.html) or open **`docs/architecture.html`** from a clone.

### 🇷🇺 Русский

Интерактивная схема: [карта архитектуры](https://htmlpreview.github.io/?https://github.com/CactKernelProject/CactOS/blob/main/docs/architecture.html) или файл **`docs/architecture.html`** локально.

---

<a id="credits-and-license"></a>

## 🙏 Credits and license

| | |
| --- | --- |
| **Developer** | [QwaYer](https://github.com/QwaYer) |
| **License** | [GNU General Public License v3.0](https://github.com/CactKernelProject/CactOS/blob/main/LICENSE) |
| **Repository** | [CactOS on GitHub](https://github.com/CactKernelProject/CactOS) |
