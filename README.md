# 🌵 CactOS: The Hybrid Monolithic Kernel

<p align="center">
  <a href="https://github.com/CactKernelProject/CactOS/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-GPLv3-blue.svg" alt="License: GPLv3">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/arch-i686-red.svg" alt="Arch: i686">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/language-C%2FRust-orange.svg" alt="Language: C/Rust">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/status-pre--1.0-yellow.svg" alt="Status: pre-1.0">
  </a>
</p>

**CactOS** — производительная монолитная (с элементами микроядра) операционная система для архитектуры i686. Низкоуровневые интерфейсы реализованы на **C**, а критическая логика управления ресурсами (менеджер памяти, планировщик, синхронизация) — на **Rust**.

[English](#english-technical-specifications) | [Русский](#russian-technical-specifications) | [Visualization](#-interactive-architecture-map)

---

<h2 id="english-technical-specifications">🇬🇧 English: Technical Specifications (pre‑1.0)</h2>

### 🧠 Boot & Core Kernel
*   **Multiboot2** parser extracting framebuffer and memory map.
*   **GDT** with ring 0/3 segments, **TSS** for stack switching.
*   **IDT**: 32 CPU exception ISRs + PIC (8259A) + PIT 100 Hz.
*   **Kernel panic** with full register dump (EAX, EBX, ECX, EDX, ESP, EBP, EIP, CS).
*   **Exception → signal** mapping: #DE/#MF → SIGFPE, #GP → SIGSEGV, others → SIGKILL.
*   **Versioning**: `VERSION` file, git commit hash, build timestamp embedded.

### 🧠 Memory Manager (Rust – `rust_mm`)
*   **PMM**: physical page allocator (`kalloc`/`kfree_page`) with reference counting.
*   **VMM**: 2‑level paging (PD→PT), identity mapping for framebuffer, `vmm_map`, `vmm_create_address_space`, `vmm_free_address_space`, `vmm_fork_address_space` (COW).
*   **Heap**: `kmalloc`/`kfree_heap` for kernel objects.
*   **Slab allocator** for fixed‑size frequent objects.
*   **mmap subsystem**: `do_mmap`/`do_munmap`/`do_mprotect`, demand paging (`PAGE_DEMAND`), zero pages (`PAGE_ZERO`), file‑backed mmap, `MAP_SHARED`/`MAP_PRIVATE`/`MAP_ANON`/`MAP_FIXED`. Per‑process `MMAP_MAX_REGIONS` slots, `mmap_table_clone` (COW for private, page sharing for shared), `mmap_handle_fault`.
*   **Copy‑on‑Write**: `vmm_map_cow`, `vmm_handle_cow`, `vmm_is_cow_page`. On fork all private pages are marked COW; write causes copy only if refcount > 1.
*   **Swap**: clock‑hand eviction (`swap_evict_page`), bitmap slot allocation, read/write via disk callbacks. `swap_out_page`/`swap_in_page`/`swap_free_slot`. `PAGE_SWAPPED` PTE marker, swap fault handling in `page_fault_handler`. Statistics: pages swapped in/out, failures.
*   **Page fault handler** handles 7 scenarios: COW write, demand alloc, zero page, swap‑in, stack grow (within `USER_STACK_LIMIT`..`USER_STACK_TOP`), mmap fault, segfault → SIGSEGV.
*   **OOM killer**: `oom_kill()` invoked when physical pages exhausted.
*   **Shared memory**: `shm_get`/`shm_at`/`shm_dt`/`shm_ctl`. Up to `SHM_MAX_SEGMENTS` segments, `SHM_MAX_PAGES` pages per segment. Lazy destroy when `nattch == 0`. `shm_detach_all` on process exit.

### ⏱️ Scheduler (Rust – `sched`)
*   **MLFQ** with 4 priority levels:
    *   RT (0) – quantum 5 ticks
    *   Interactive (1) – quantum 1 tick
    *   Normal (2) – quantum 2 ticks
    *   Background (3) – quantum 4 ticks
*   **Priority boost** every 50 ticks: all tasks ≥ Normal promoted to Interactive.
*   **Voluntary block bonus**: tasks blocking before half quantum expire are boosted one level.
*   **Sleep queue** with `wake_expired_sleepers()` each tick.
*   **Reentrance guard**: `SCHEDULE_IN_PROGRESS` atomic.
*   **Timer wheel**: `timer_wheel_tick()` + `check_alarm_timers()` per tick.

### 🔒 Synchronization (Rust)
*   **Spinlock**: CAS‑based (`spinlock_acquire`/`spinlock_release`).
*   **IRQ Spinlock**: CLI/STI + spinlock with EFLAGS save/restore.
*   **Mutex**: wait queue (up to 64 waiters), `mutex_lock`/`mutex_unlock`/`mutex_trylock`.
*   **Semaphore**: counting semaphore with CAS fast path.

### 🧬 Processes & Signals
*   **TaskStruct** (~11 852 bytes) contains: `esp`, `pid`, `state`, `is_kernel`, `stack_base`, `ustack_phys`/`virt`, `page_directory`, MLFQ fields, 13 signals, `signal_handlers[13]`, `fd_table[256]`, `fd_offset[256]`, `fd_flags[256]`, `fd_cloexec[256]`, `ProcPageTracker`, `MmapTable`, `DynCtx`, `parent_pid`, `exit_code`, `wait_for_pid`, `brk_start`/`brk_current`, `sleep_until`, `cwd[256]`, `uid`/`gid`/`euid`/`egid`, `shm_attachments[16]`.
*   **fork**: COW cloning via `vmm_fork_address_space`, stack copy, fd refcount increment, SHM reset, `mmap_table_clone`.
*   **exec**: ELF loading, new address space, close `FD_CLOEXEC`, brk recalculation, setup sigreturn trampoline, build argv/envp on user stack.
*   **exit / waitpid**: Zombie state, `SIGCHLD` → parent, `task_reap()` frees all resources.
*   **Signals**: 13 POSIX signals (SIGKILL, SIGTERM, SIGSTOP, SIGCONT, SIGPIPE, SIGALRM, SIGCHLD, SIGFPE, SIGSEGV, SIGWINCH, SIGHUP, SIGINT, SIGQUIT). `sigaction`, `sigprocmask`/`sigpending`/`sigsuspend`, `alarm`/`setitimer`, sigreturn trampoline at user page `0xBFFFE000` with `int 0x80`.

### 📦 ELF & Dynamic Linking
*   **ELF loader**: supports `ET_EXEC`/`ET_DYN`, `PT_LOAD` segments, static and dynamic binaries.
*   **Dynamic linker**: `dyn_ctx_t` with loaded SO table (up to `SO_TABLE_MAX`), search path `/lib:/usr/lib`, recursive `DT_NEEDED` loading.
*   **Relocations**: `R_386_NONE`, `R_386_32`, `R_386_PC32`, `R_386_GLOB_DAT`, `R_386_JMP_SLOT`, `R_386_RELATIVE`, `R_386_COPY`.
*   `DT_INIT`/`DT_FINI`, `DT_HASH` for symbol lookup.

### 📁 VFS & Filesystems
*   **VFS**: mount table (32 slots), `vfs_walk_path`, symlinks with depth limit (`ELOOP`), refcounting, permission checks (owner/group/other, root bypass). Operations: `read`/`write`/`open`/`close`/`ioctl`/`readdir`/`finddir`/`listdir`/`create`/`delete`/`mkdir`/`rmdir`/`rename`/`symlink`/`link`/`unlink`.
*   **ext4**: ~40 KiB code, read/write, inode ops.
*   **devfs**: devices as VFS nodes.
*   **procfs**: `/proc/cmd` for shell commands, `procfs_register_cmd`, `procfs_set_meminfo`.
*   **mntfs**: mount management (`mount`/`umount`/`list`), auto‑mount at boot, persistent mounts.
*   **etcfs**: `/etc/passwd`‑like system — `etcfs_uid_to_name`, `etcfs_name_to_uid`, `etcfs_name_to_gid`.
*   **pipes**: `pipe_create`, read/write, integrated with fd table.
*   **Stubs**: btrfs (7 bytes), exFAT (7 bytes), ramfs (7 bytes).

### 💾 Block I/O & Drivers
*   **PCI**: bus scan, enumeration, driver binding, loader.
*   **AHCI**: SATA controller driver.
*   **NVMe**: `nvme_init`, `nvme_read_sector`/`nvme_write_sector`.
*   **blkdev**: abstract block layer (`blkdev_read_sector`/`blkdev_write_sector`).
*   **Buffer cache** (`buf`) and **page cache** (`pagecache`, `pc_init`, `pc_flush_dev`).
*   **xHCI**: USB 3.0 host controller (~32 KiB code).
*   **USB HID**: keyboard/mouse over USB.
*   **USB Hub**: cascading support.
*   **PS/2**: keyboard (scan codes) + mouse.
*   **virtio‑net**: network driver for QEMU/KVM.
*   **Framebuffer**: 32 bpp, 8×8 font with ×2 scaling, `fb_put_pixel`, `fb_fill_rect`, `fb_clear`.

### 🌐 Network Stack
*   **skb**: `skb_alloc`/`skb_free`/`skb_push`/`skb_put` – packet buffer.
*   **Ethernet**: `ethernet_input` demux by EtherType.
*   **ARP**: cache, request/reply.
*   **IPv4**: `ip_output`, `ip_pseudo_checksum`, `inet_checksum`.
*   **ICMP**: `icmp_send_echo_request` (ping).
*   **UDP**: `udp_output`, `udp_sock_alloc`/`udp_sock_recv`/`udp_sock_free`.
*   **TCP**: full state machine (`CLOSED` → `LISTEN` → `SYN_SENT` → `SYN_RECEIVED` → `ESTABLISHED` → `FIN_WAIT_1` → `FIN_WAIT_2` → `TIME_WAIT` → `CLOSE_WAIT` → `LAST_ACK`). RST handling, child socket for `accept`, `tcp_send`/`tcp_recv`/`tcp_close`/`tcp_shutdown_wr`, RX ring buffer (`TCP_RX_BUF_SIZE`), `on_data`/`on_event` callbacks.
*   **Sockets**: 16‑slot kernel socket table, VFS integration (`read`/`write`/`close`), `ksock_create`/`ksock_tcp_accept`/`ksock_shutdown`, `SHUT_RD`/`SHUT_WR`/`SHUT_RDWR`.
*   **knetd**: kernel‑space network daemon on semaphore, `net_poll`.
*   Static IP (`MY_IP`), no DHCP/DNS.

### 📞 System Calls (73 total)
| Group        | Syscalls |
|--------------|----------|
| **Files**    | `open`, `read`, `write`, `close`, `create`, `delete`, `lseek`, `stat`, `fstat`, `getdents`, `rename`, `mkdir`, `rmdir`, `fcntl`, `ioctl`, `symlink`, `readlink`, `link`, `unlink` |
| **Processes**| `fork`, `exec`, `exit`, `kill`, `signal`, `sigaction`, `sigreturn`, `sigprocmask`, `sigpending`, `sigsuspend`, `getpid`, `getppid`, `waitpid`, `sleep`, `brk`, `alarm`, `setitimer` |
| **Memory**   | `mmap`, `munmap`, `mprotect`, `shmget`, `shmat`, `shmdt`, `shmctl` |
| **Network**  | `socket`, `bind`, `connect`, `listen`, `accept`, `send`, `recv`, `sendto`, `recvfrom`, `shutdown`, `setsockopt`, `getsockopt`, `select`, `poll` |
| **I/O**      | `pipe`, `dup2`, `getcwd`, `chdir` |
| **Users**    | `getuid`, `getgid`, `setuid`, `setgid`, `geteuid`, `getegid`, `chmod`, `chown` |
| **Time**     | `gettimeofday`, `clock_gettime`, `nanosleep` |
| **Misc**     | `print` |

---

<h2 id="russian-technical-specifications">🇷🇺 Русский: Технические характеристики (pre‑1.0)</h2>

### 🧠 Загрузка и ядро
*   Парсер **Multiboot2** с извлечением framebuffer и карты памяти.
*   **GDT** с сегментами ring 0 / ring 3, **TSS** для переключения стеков.
*   **IDT**: 32 ISR (исключения CPU) + PIC (8259A) + PIT 100 Гц.
*   **Kernel panic** с дампом регистров (EAX, EBX, ECX, EDX, ESP, EBP, EIP, CS).
*   **Exception → signal**: #DE/#MF → SIGFPE, #GP → SIGSEGV, остальные → SIGKILL.
*   **Версионирование**: файл `VERSION`, хеш коммита git, метка времени сборки в бинарнике.

### 🧠 Менеджер памяти (Rust — `rust_mm`)
*   **PMM**: физический аллокатор страниц (`kalloc`/`kfree_page`), подсчёт ссылок.
*   **VMM**: 2‑уровневая страничная адресация (PD→PT), identity mapping для framebuffer, `vmm_map`, `vmm_create_address_space`, `vmm_free_address_space`, `vmm_fork_address_space` (COW).
*   **Heap**: `kmalloc`/`kfree_heap` для объектов ядра.
*   **Slab**: аллокатор для частых объектов фиксированного размера.
*   **mmap**: полная реализация — `do_mmap`/`do_munmap`/`do_mprotect`, demand paging (`PAGE_DEMAND`), zero pages (`PAGE_ZERO`), file‑backed mmap, `MAP_SHARED`/`MAP_PRIVATE`/`MAP_ANON`/`MAP_FIXED`. На процесс выделяется до `MMAP_MAX_REGIONS` слотов, `mmap_table_clone` (COW для private, общий доступ для shared), `mmap_handle_fault`.
*   **COW**: `vmm_map_cow`, `vmm_handle_cow`, `vmm_is_cow_page`. При fork все private страницы помечаются COW; при записи копируются, только если refcount > 1.
*   **Swap**: clock‑hand eviction (`swap_evict_page`), битовая карта слотов, запись/чтение через callback‑функции. `swap_out_page`/`swap_in_page`/`swap_free_slot`. Маркер `PAGE_SWAPPED` в PTE, обработка swap fault в `page_fault_handler`. Статистика: pages_swapped_in/out, failures.
*   **Page fault handler** обрабатывает 7 сценариев: COW write, demand alloc, zero page, swap‑in, рост стека (в пределах `USER_STACK_LIMIT`..`USER_STACK_TOP`), mmap fault, SEGFAULT → SIGSEGV.
*   **OOM killer**: `oom_kill()` вызывается при нехватке физических страниц.
*   **Shared memory**: `shm_get`/`shm_at`/`shm_dt`/`shm_ctl`. До `SHM_MAX_SEGMENTS` сегментов, до `SHM_MAX_PAGES` страниц на сегмент. Lazy destroy при `nattch == 0`. `shm_detach_all` при завершении процесса.

### ⏱️ Планировщик (Rust — `sched`)
*   **MLFQ** с 4 уровнями приоритета:
    *   RT (0) — квант 5 тиков
    *   Interactive (1) — квант 1 тик
    *   Normal (2) — квант 2 тика
    *   Background (3) — квант 4 тика
*   **Priority boost** каждые 50 тиков: задачи ≥ Normal поднимаются до Interactive.
*   **Voluntary block bonus**: задачи, блокирующиеся до половины кванта, повышаются на один уровень.
*   **Sleep queue** с пробуждением `wake_expired_sleepers()` каждый тик.
*   **Reentrance guard**: `SCHEDULE_IN_PROGRESS` (атомарный).
*   **Timer wheel**: `timer_wheel_tick()` + `check_alarm_timers()` на каждом тике.

### 🔒 Синхронизация (Rust)
*   **Spinlock**: на базе CAS (`spinlock_acquire`/`spinlock_release`).
*   **IRQ Spinlock**: CLI/STI + spinlock с сохранением/восстановлением EFLAGS.
*   **Mutex**: очередь ожидания (до 64 waiters), `mutex_lock`/`mutex_unlock`/`mutex_trylock`.
*   **Semaphore**: счётный семафор, `sema_init`/`sema_down`/`sema_up`, быстрый путь через CAS.

### 🧬 Процессы и сигналы
*   **TaskStruct** (~11 852 байта): `esp`, `pid`, `state`, `is_kernel`, `stack_base`, `ustack_phys`/`virt`, `page_directory`, поля MLFQ, 13 сигналов, `signal_handlers[13]`, `fd_table[256]`, `fd_offset[256]`, `fd_flags[256]`, `fd_cloexec[256]`, `ProcPageTracker`, `MmapTable`, `DynCtx`, `parent_pid`, `exit_code`, `wait_for_pid`, `brk_start`/`brk_current`, `sleep_until`, `cwd[256]`, `uid`/`gid`/`euid`/`egid`, `shm_attachments[16]`.
*   **fork**: COW‑клонирование через `vmm_fork_address_space`, копирование стека, инкремент refcount fd, сброс SHM, `mmap_table_clone`.
*   **exec**: загрузка ELF, новое адресное пространство, закрытие `FD_CLOEXEC`, пересчёт brk, установка sigreturn trampoline, построение argv/envp на пользовательском стеке.
*   **exit / waitpid**: состояние Zombie, SIGCHLD → родитель, `task_reap()` освобождает все ресурсы.
*   **Сигналы**: 13 сигналов POSIX (SIGKILL, SIGTERM, SIGSTOP, SIGCONT, SIGPIPE, SIGALRM, SIGCHLD, SIGFPE, SIGSEGV, SIGWINCH, SIGHUP, SIGINT, SIGQUIT). `sigaction`, `sigprocmask`/`sigpending`/`sigsuspend`, `alarm`/`setitimer`, sigreturn trampoline на странице `0xBFFFE000` с `int 0x80`.

### 📦 ELF и динамическая линковка
*   **ELF loader**: поддержка `ET_EXEC`/`ET_DYN`, сегментов `PT_LOAD`, статических и динамических бинарников.
*   **Dynamic linker**: `dyn_ctx_t` с таблицей загруженных SO (до `SO_TABLE_MAX`), путь поиска `/lib:/usr/lib`, рекурсивная загрузка `DT_NEEDED`.
*   **Релокации**: `R_386_NONE`, `R_386_32`, `R_386_PC32`, `R_386_GLOB_DAT`, `R_386_JMP_SLOT`, `R_386_RELATIVE`, `R_386_COPY`.
*   `DT_INIT`/`DT_FINI`, `DT_HASH` для поиска символов.

### 📁 VFS и файловые системы
*   **VFS**: таблица монтирования (32 слота), `vfs_walk_path`, symlink с ограничением глубины (`ELOOP`), подсчёт ссылок, проверка прав (владелец/группа/остальные, обход для root). Операции: `read`/`write`/`open`/`close`/`ioctl`/`readdir`/`finddir`/`listdir`/`create`/`delete`/`mkdir`/`rmdir`/`rename`/`symlink`/`link`/`unlink`.
*   **ext4**: ~40 KiB кода, чтение/запись, операции с inode.
*   **devfs**: устройства как VFS‑узлы.
*   **procfs**: `/proc/cmd` для команд оболочки, `procfs_register_cmd`, `procfs_set_meminfo`.
*   **mntfs**: управление монтированием (`mount`/`umount`/`list`), auto‑mount при загрузке, постоянные точки монтирования.
*   **etcfs**: система, подобная `/etc/passwd` — `etcfs_uid_to_name`, `etcfs_name_to_uid`, `etcfs_name_to_gid`.
*   **pipes**: `pipe_create`, чтение/запись, интеграция с таблицей файловых дескрипторов.
*   **Заглушки**: btrfs (7 байт), exFAT (7 байт), ramfs (7 байт).

### 💾 Блочный ввод‑вывод и драйверы
*   **PCI**: сканирование шины, перечисление, привязка драйверов, загрузчик.
*   **AHCI**: драйвер SATA‑контроллера.
*   **NVMe**: `nvme_init`, `nvme_read_sector`/`nvme_write_sector`.
*   **blkdev**: абстрактный блочный слой (`blkdev_read_sector`/`blkdev_write_sector`).
*   **Буферный кеш** (`buf`) и **страничный кеш** (`pagecache`, `pc_init`, `pc_flush_dev`).
*   **xHCI**: контроллер USB 3.0 (~32 KiB кода).
*   **USB HID**: клавиатура/мышь через USB.
*   **USB Hub**: поддержка каскадирования.
*   **PS/2**: клавиатура (скан‑коды) + мышь.
*   **virtio‑net**: сетевой драйвер для QEMU/KVM.
*   **Framebuffer**: 32 bpp, шрифт 8×8 с масштабированием ×2, `fb_put_pixel`, `fb_fill_rect`, `fb_clear`.

### 🌐 Сетевой стек
*   **skb**: `skb_alloc`/`skb_free`/`skb_push`/`skb_put` — буфер сетевых пакетов.
*   **Ethernet**: `ethernet_input` — демультиплексор по EtherType.
*   **ARP**: кеш, запрос/ответ.
*   **IPv4**: `ip_output`, `ip_pseudo_checksum`, `inet_checksum`.
*   **ICMP**: `icmp_send_echo_request` (ping).
*   **UDP**: `udp_output`, `udp_sock_alloc`/`udp_sock_recv`/`udp_sock_free`.
*   **TCP**: полный конечный автомат (`CLOSED` → `LISTEN` → `SYN_SENT` → `SYN_RECEIVED` → `ESTABLISHED` → `FIN_WAIT_1` → `FIN_WAIT_2` → `TIME_WAIT` → `CLOSE_WAIT` → `LAST_ACK`). Обработка RST, дочерний сокет для `accept`, `tcp_send`/`tcp_recv`/`tcp_close`/`tcp_shutdown_wr`, кольцевой буфер приёма (`TCP_RX_BUF_SIZE`), колбэки `on_data`/`on_event`.
*   **Сокеты**: 16‑слотовая таблица сокетов ядра, интеграция с VFS (`read`/`write`/`close`), `ksock_create`/`ksock_tcp_accept`/`ksock_shutdown`, `SHUT_RD`/`SHUT_WR`/`SHUT_RDWR`.
*   **knetd**: сетевой демон уровня ядра на семафоре, `net_poll`.
*   Статический IP (`MY_IP`), DHCP/DNS отсутствуют.

### 📞 Системные вызовы (всего 73)
| Группа        | Вызовы |
|---------------|--------|
| **Файлы**     | `open`, `read`, `write`, `close`, `create`, `delete`, `lseek`, `stat`, `fstat`, `getdents`, `rename`, `mkdir`, `rmdir`, `fcntl`, `ioctl`, `symlink`, `readlink`, `link`, `unlink` |
| **Процессы**  | `fork`, `exec`, `exit`, `kill`, `signal`, `sigaction`, `sigreturn`, `sigprocmask`, `sigpending`, `sigsuspend`, `getpid`, `getppid`, `waitpid`, `sleep`, `brk`, `alarm`, `setitimer` |
| **Память**    | `mmap`, `munmap`, `mprotect`, `shmget`, `shmat`, `shmdt`, `shmctl` |
| **Сеть**      | `socket`, `bind`, `connect`, `listen`, `accept`, `send`, `recv`, `sendto`, `recvfrom`, `shutdown`, `setsockopt`, `getsockopt`, `select`, `poll` |
| **Ввод‑вывод**| `pipe`, `dup2`, `getcwd`, `chdir` |
| **Пользователи**| `getuid`, `getgid`, `setuid`, `setgid`, `geteuid`, `getegid`, `chmod`, `chown` |
| **Время**     | `gettimeofday`, `clock_gettime`, `nanosleep` |
| **Прочее**    | `print` |

---

## 📊 Interactive Architecture Map

Project includes a **React‑based visualization tool** to explore the system architecture:
* **Visualizer:** An interactive HTML/React dashboard showing memory regions, driver bindings, and networking layers.
* **Access:** Open the [architecture map](https://htmlpreview.github.io/?https://github.com/CactKernelProject/CactOS/blob/main/docs/architecture.html) (or download and open locally).

---

**Developer:** [QwaYer](https://github.com/QwaYer)  
**License:** GNU General Public License v3.0  
**Repository:** [CactOS](https://github.com/CactKernelProject/CactOS)
