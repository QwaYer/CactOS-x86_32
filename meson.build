# ==============================================================================
# CactOS — Meson build system (workspace integrator)
# ==============================================================================
#
#   meson setup build-meson
#   ninja -C build-meson stage       # libc → shell/supervisor → userbins → drivers
#                                    #   → LocalRepo image  (the Makefile's
#                                    #   `localrepo` chain, without the ISO)
#   ninja -C build-meson kernel      # kernel.bin only
#   ninja -C build-meson iso         # build the ISO with CactBridge (non-GUI)
#   ninja -C build-meson iso-gui     # build the GUI ISO with CactBridge
#   ninja -C build-meson disk        # create the empty ext4 test disk
#   ninja -C build-meson clean
#
# This repo owns no sources: it drives the sibling repositories through their
# Meson targets, so no cross file is needed.  Meson reserves install/test/clean,
# hence "stage"; the sibling "stage" targets copy into the LocalRepo tree.
# ==============================================================================

project('cactos',
  version: '1.0.0',
  meson_version: '>=1.0.0')

fs = import('fs')
bash = find_program('bash')
python3 = find_program('python3')
ninja = find_program('ninja')

src_root = meson.project_source_root()
siblings = fs.parent(src_root)

_bridge = get_option('bridge')
bridge = _bridge.startswith('/') ? _bridge : src_root / _bridge

kern = siblings / 'CactKernel-x86_32'
libc = siblings / 'CactLibc-x86_32'
sole = siblings / 'Cactsole-x86_32'
cgoct = siblings / 'Cgoct-x86_32'
userbins = siblings / 'CactUserBins-x86_32'
repo = siblings / 'LocalRepoCactOS-x86_32'

# Module repos whose .cctk blobs belong in the image.  The canonical list is
# CactBridge's drivers.list (one repo name per line, "#" comments) so the ISO
# builder and this integrator cannot drift; see PLAN-2.0.0 P3.1.
_driver_list = bridge / 'drivers.list'
if not fs.exists(_driver_list)
  error('driver list not found: ' + _driver_list + ' (set -Dbridge=... to the CactBridge dir)')
endif
_driver_names = []
foreach _line : fs.read(_driver_list).split('\n')
  _name = _line.split('#')[0].strip()
  if _name != ''
    _driver_names += _name
  endif
endforeach

# ------------------------------------------------------------------------------
# Sibling invocation: configure on first use, then run a target
# ------------------------------------------------------------------------------

_step_tpl = ('d="@0@"; ' +
             'if [ ! -f "$d/build-meson/build.ninja" ]; then ' +
             'meson setup "$d/build-meson" "$d" --cross-file "$d/cross/i686-cact-clang.ini" @1@; ' +
             'else meson configure "$d/build-meson" @1@ > /dev/null; fi; ' +
             ninja.full_path() + ' -C "$d/build-meson" @2@; ')

# Siblings that need no options (their defaults point at the right paths).
_libc_tpl = ('d="@0@"; ' +
             'if [ ! -f "$d/build-meson/build.ninja" ]; then ' +
             'meson setup "$d/build-meson" --cross-file "$d/cross/i686-cact-clang.ini"; fi; ' +
             ninja.full_path() + ' -C "$d/build-meson" @1@; ')

_cactlib_opt = '-Dcactlib="' + libc + '"'

_script_libc = _libc_tpl.format(libc, '')
_script_kernel = _libc_tpl.format(kern, 'kernel.bin')
_script_sole = _step_tpl.format(sole, _cactlib_opt, '')
_script_cgoct = _step_tpl.format(cgoct, _cactlib_opt, '')
_script_userbins = _step_tpl.format(
  userbins,
  _cactlib_opt + ' -Dcactsoleinc="' + sole / 'include' + '"' +
  ' -Dlr_bin="' + repo / 'lib/bin' + '" -Dlr_sbin="' + repo / 'lib/sbin' + '"',
  'stage')

_script_drivers = ''
foreach d : _driver_names
  _dir = siblings / (d + '-for-Cact-x86_32')
  _script_drivers += (
    'if [ -f "' + _dir + '/meson.build" ]; then ' +
    _step_tpl.format(_dir, '-Dkern_root="' + kern + '" -Dlocal_repo="' + repo + '"', 'stage') +
    'fi; '
  )
endforeach

_script_localrepo = _step_tpl.format(
  repo,
  '-Dcactlib_dir="' + libc + '"' +
  ' -Dcactsole_bin="' + sole / 'build-meson/cactsole' + '"' +
  ' -Dcgoct_bin="' + cgoct / 'build-meson/cgoct' + '"' +
  ' -Duserbins_mk="' + userbins + '"' +
  ' -Dcactsoleinc="' + sole / 'include' + '"',
  'stage')

# The full chain the Makefile's `localrepo` target expressed through make
# prerequisites: libc → cactsole/cgoct → userbins → drivers → image.
_script_stage = (
  _script_libc + _script_sole + _script_cgoct +
  _script_userbins + _script_drivers + _script_localrepo
)

run_target('libc',
  command: [bash, '-c', 'set -e; ' + _script_libc])

run_target('cactsole',
  command: [bash, '-c', 'set -e; ' + _script_libc + _script_sole])

run_target('cgoct',
  command: [bash, '-c', 'set -e; ' + _script_libc + _script_cgoct])

run_target('userbins',
  command: [bash, '-c', 'set -e; ' + _script_libc + _script_sole +
            _script_userbins])

run_target('drivers',
  command: [bash, '-c', 'set -e; ' + _script_drivers])

run_target('kernel',
  command: [bash, '-c', 'set -e; ' + _script_kernel])

run_target('localrepo',
  command: [bash, '-c', 'set -e; ' + _script_stage])

# Everything up to (but excluding) the ISO.
run_target('stage',
  command: [bash, '-c', 'set -e; ' + _script_stage + _script_kernel])

# The ISOs are assembled by CactBridge (it builds the kernel itself).
run_target('iso',
  command: [python3, bridge / 'build.py', '--non-gui-iso'])

run_target('iso-gui',
  command: [python3, bridge / 'build.py', '--gui-iso'])

run_target('disk',
  command: [bash, kern / 'build_disk.sh'])

# Meson reserves "clean", so the Makefile's `clean` becomes "distclean"; the
# siblings' own targets handle their trees.
_script_clean = ''
foreach d : [kern, libc, sole, cgoct, userbins, repo]
  _script_clean += (
    'if [ -d "' + d + '/build-meson" ]; then ' +
    ninja.full_path() + ' -C "' + d + '/build-meson" clean; fi; '
  )
endforeach
foreach d : _driver_names
  _dir = siblings / (d + '-for-Cact-x86_32')
  _script_clean += (
    'if [ -d "' + _dir + '/build-meson" ]; then ' +
    ninja.full_path() + ' -C "' + _dir + '/build-meson" clean; fi; '
  )
endforeach

run_target('distclean',
  command: [bash, '-c', 'set -e; ' + _script_clean])
