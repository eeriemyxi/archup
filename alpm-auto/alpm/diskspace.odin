/*
 *  diskspace.h
 *
 *  Copyright (c) 2010-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
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


Mount_Used_Level :: enum u32 {
	REMOVE  = 1,
	INSTALL = 2,
}

Mount_Fsinfo :: enum u32 {
	UNLOADED = 0,
	LOADED   = 1,
	FAIL     = 2,
}

_Alpm_Mountpoint :: struct {
	/* mount point information */
	mount_dir:     cstring,
	mount_dir_len: i32,

	/* storage for additional disk usage calculations */
	blocks_needed:     posix.blkcnt_t,
	max_blocks_needed: posix.blkcnt_t,
	used:              Mount_Used_Level,
	read_only:         i32,
	fsinfo_loaded:     Mount_Fsinfo,
	fsp:               i32,
}

Mountpoint :: _Alpm_Mountpoint

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_check_diskspace     :: proc(handle: ^Handle) -> i32 ---
	_alpm_check_downloadspace :: proc(handle: ^Handle, cachedir: cstring, num_files: i32, file_sizes: ^posix.off_t) -> i32 ---
}

