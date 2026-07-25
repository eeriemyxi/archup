/*
 *  package.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *  Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
 *  Copyright (c) 2006 by David Kimpe <dnaku@frugalware.org>
 *  Copyright (c) 2005, 2006 by Christian Hamar <krics@linuxforum.hu>
 *  Copyright (c) 2005, 2006 by Miklos Vajna <vmiklos@frugalware.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package alpm_auto

import "core:sys/posix"

foreign import lib "system:alpm"
_ :: lib

import "core:c/libc"
import "core:sys/linux"


/** Package operations struct. This struct contains function pointers to
* all methods used to access data in a package to allow for things such
* as lazy package initialization (such as used by the file backend). Each
* backend is free to define a struct containing pointers to a specific
* implementation of these methods. Some backends may find using the
* defined default_pkg_ops struct to work just fine for their needs.
*/
Pkg_Operations :: struct {
	get_base:         proc "c" (^Pkg) -> cstring,
	get_desc:         proc "c" (^Pkg) -> cstring,
	get_url:          proc "c" (^Pkg) -> cstring,
	get_builddate:    proc "c" (^Pkg) -> Time,
	get_installdate:  proc "c" (^Pkg) -> Time,
	get_packager:     proc "c" (^Pkg) -> cstring,
	get_arch:         proc "c" (^Pkg) -> cstring,
	get_isize:        proc "c" (^Pkg) -> posix.off_t,
	get_reason:       proc "c" (^Pkg) -> Pkgreason,
	get_validation:   proc "c" (^Pkg) -> i32,
	has_scriptlet:    proc "c" (^Pkg) -> i32,
	get_licenses:     proc "c" (^Pkg) -> ^List,
	get_groups:       proc "c" (^Pkg) -> ^List,
	get_depends:      proc "c" (^Pkg) -> ^List,
	get_optdepends:   proc "c" (^Pkg) -> ^List,
	get_checkdepends: proc "c" (^Pkg) -> ^List,
	get_makedepends:  proc "c" (^Pkg) -> ^List,
	get_conflicts:    proc "c" (^Pkg) -> ^List,
	get_provides:     proc "c" (^Pkg) -> ^List,
	get_replaces:     proc "c" (^Pkg) -> ^List,
	get_files:        proc "c" (^Pkg) -> ^Filelist,
	get_backup:       proc "c" (^Pkg) -> ^List,
	get_xdata:        proc "c" (^Pkg) -> ^List,
	changelog_open:   proc "c" (^Pkg) -> rawptr,
	size_t:           proc "c" (_: rawptr, size_t: i32, _: ^Pkg, _: rawptr, changelog_read: ^i32) -> proc "c" (rawptr, i32, ^Pkg, rawptr) -> i32,
	changelog_close:  proc "c" (^Pkg, rawptr) -> i32,
	mtree_open:       proc "c" (^Pkg) -> ^Archive,
	mtree_next:       proc "c" (^Pkg, ^Archive, ^^Archive_Entry) -> i32,
	mtree_close:      proc "c" (^Pkg, ^Archive) -> i32,
	force_load:       proc "c" (^Pkg) -> i32,
}

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_file_copy             :: proc(dest: ^libc.FILE, src: ^libc.FILE) -> ^libc.FILE ---
	_alpm_pkg_new               :: proc() -> ^Pkg ---
	_alpm_pkg_dup               :: proc(pkg: ^Pkg, new_ptr: ^^Pkg) -> i32 ---
	_alpm_pkg_free              :: proc(pkg: ^Pkg) ---
	_alpm_pkg_free_trans        :: proc(pkg: ^Pkg) ---
	_alpm_pkg_validate_internal :: proc(handle: ^Handle, pkgfile: cstring, syncpkg: ^Pkg, level: i32, sigdata: ^^Siglist, validation: ^i32) -> i32 ---
	_alpm_pkg_load_internal     :: proc(handle: ^Handle, pkgfile: cstring, full: i32) -> ^Pkg ---
	_alpm_pkg_cmp               :: proc(p1: rawptr, p2: rawptr) -> i32 ---
	_alpm_pkg_compare_versions  :: proc(local_pkg: ^Pkg, pkg: ^Pkg) -> i32 ---
	_alpm_pkg_parse_xdata       :: proc(_string: cstring) -> ^Pkg_Xdata ---
	_alpm_pkg_xdata_free        :: proc(pd: ^Pkg_Xdata) ---
	_alpm_pkg_check_meta        :: proc(pkg: ^Pkg) -> i32 ---
}

