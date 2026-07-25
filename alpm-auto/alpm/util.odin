/*
 *  util.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *  Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
 *  Copyright (c) 2005 by Christian Hamar <krics@linuxforum.hu>
 *  Copyright (c) 2006 by David Kimpe <dnaku@frugalware.org>
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

import "core:c"
import "core:sys/posix"

foreign import lib "system:alpm"
_ :: lib

import "core:c/libc"
import "core:sys/linux"


@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_alloc_fail :: proc(size: i32) ---
}

O_BINARY :: 0

/**
* Used as a buffer/state holder for _alpm_archive_fgets().
*/
Archive_Read_Buffer :: struct {
	line:           cstring,
	line_offset:    cstring,
	line_size:      i32,
	max_line_size:  i32,
	real_line_size: i32,
	block:          cstring,
	block_offset:   cstring,
	block_size:     i32,
	ret:            i32,
}

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_makepath           :: proc(path: cstring) -> i32 ---
	_alpm_makepath_mode      :: proc(path: cstring, mode: u32) -> i32 ---
	_alpm_copyfile           :: proc(src: cstring, dest: cstring) -> i32 ---
	_alpm_get_fullpath       :: proc(path: cstring, filename: cstring, suffix: cstring) -> cstring ---
	_alpm_strip_newline      :: proc(str: cstring, len: i32) -> i32 ---
	_alpm_open_archive       :: proc(handle: ^Handle, path: cstring, buf: ^linux.Stat, archive: ^^Archive, error: Errno) -> i32 ---
	_alpm_unpack_single      :: proc(handle: ^Handle, archive: cstring, prefix: cstring, filename: cstring) -> i32 ---
	_alpm_unpack             :: proc(handle: ^Handle, archive: cstring, prefix: cstring, list: ^List, breakfirst: i32) -> i32 ---
	_alpm_files_in_directory :: proc(handle: ^Handle, path: cstring, full_count: i32) -> c.ssize_t ---
}

_Alpm_Cb_Io :: proc "c" (buf: rawptr, len: c.ssize_t, ctx: rawptr) -> c.ssize_t

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_reset_signals  :: proc() ---
	_alpm_run_chroot     :: proc(handle: ^Handle, cmd: cstring, argv: [^]cstring, in_cb: _Alpm_Cb_Io, in_ctx: rawptr) -> i32 ---
	_alpm_ldconfig       :: proc(handle: ^Handle) -> i32 ---
	_alpm_str_cmp        :: proc(s1: rawptr, s2: rawptr) -> i32 ---
	_alpm_filecache_find :: proc(handle: ^Handle, filename: cstring) -> cstring ---

	/* Checks whether a file exists in cache */
	_alpm_filecache_exists              :: proc(handle: ^Handle, filename: cstring) -> i32 ---
	_alpm_filecache_setup               :: proc(handle: ^Handle) -> cstring ---
	_alpm_temporary_download_dir_setup  :: proc(dir: cstring, user: cstring) -> cstring ---
	_alpm_remove_temporary_download_dir :: proc(dir: cstring) ---

	/* Unlike many uses of alpm_pkgvalidation_t, _alpm_test_checksum expects
	* an enum value rather than a bitfield. */
	_alpm_test_checksum    :: proc(filepath: cstring, expected: cstring, type: Pkgvalidation) -> i32 ---
	_alpm_archive_fgets    :: proc(a: ^Archive, b: ^Archive_Read_Buffer) -> i32 ---
	_alpm_splitname        :: proc(target: cstring, name: ^cstring, version: ^cstring, name_hash: ^c.ulong) -> i32 ---
	_alpm_hash_sdbm        :: proc(str: cstring) -> c.ulong ---
	_alpm_strtoofft        :: proc(line: cstring) -> posix.off_t ---
	_alpm_parsedate        :: proc(line: cstring) -> Time ---
	_alpm_raw_cmp          :: proc(first: cstring, second: cstring) -> i32 ---
	_alpm_raw_ncmp         :: proc(first: cstring, second: cstring, max: i32) -> i32 ---
	_alpm_access           :: proc(handle: ^Handle, dir: cstring, file: cstring, amode: i32) -> i32 ---
	_alpm_fnmatch_patterns :: proc(patterns: ^List, _string: cstring) -> i32 ---
	_alpm_fnmatch          :: proc(pattern: rawptr, _string: rawptr) -> i32 ---
	_alpm_realloc          :: proc(data: ^rawptr, current: ^i32, required: i32) -> rawptr ---
	_alpm_greedy_grow      :: proc(data: ^rawptr, current: ^i32, required: i32) -> rawptr ---
	_alpm_read_file        :: proc(filepath: cstring, data: ^^u8, data_len: ^i32) -> Errno ---
	strsep                 :: proc(^cstring, cstring) -> cstring ---
}

