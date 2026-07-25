/*
 *  trans.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *  Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
 *  Copyright (c) 2005 by Christian Hamar <krics@linuxforum.hu>
 *  Copyright (c) 2006 by Miklos Vajna <vmiklos@frugalware.org>
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

foreign import lib "system:alpm"
_ :: lib

import "core:c/libc"
import "core:sys/linux"


_Alpm_Transstate :: enum u32 {
	IDLE        = 0,
	INITIALIZED = 1,
	PREPARED    = 2,
	DOWNLOADING = 3,
	COMMITING   = 4,
	COMMITED    = 5,
	INTERRUPTED = 6,
}

Transstate :: _Alpm_Transstate

/* Transaction */
_Alpm_Trans :: struct {
	/* bitfield of alpm_transflag_t flags */
	flags:        i32,
	state:        Transstate,
	unresolvable: ^List, /* list of (alpm_pkg_t *) */
	add:          ^List, /* list of (alpm_pkg_t *) */
	remove:       ^List, /* list of (alpm_pkg_t *) */
	skip_remove:  ^List, /* list of (char *) */
}

/* Transaction */
Trans :: _Alpm_Trans

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_trans_free :: proc(trans: ^Trans) ---

	/* flags is a bitfield of alpm_transflag_t flags */
	_alpm_trans_init   :: proc(trans: ^Trans, flags: i32) -> i32 ---
	_alpm_runscriptlet :: proc(handle: ^Handle, filepath: cstring, script: cstring, ver: cstring, oldver: cstring, is_archive: i32) -> i32 ---
}

