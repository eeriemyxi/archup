/*
 *  db.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *  Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
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


/* Database entries */
_Alpm_Dbinfrq :: enum u32 {
	BASE      = 1,
	DESC      = 2,
	FILES     = 4,
	SCRIPTLET = 8,
	DSIZE     = 16,

	/* ALL should be info stored in the package or database */
	ALL       = 31,
	ERROR     = 1073741824,
}

/* Database entries */
Dbinfrq :: _Alpm_Dbinfrq

/** Database status. Bitflags. */
_Alpm_Dbstatus :: enum u32 {
	VALID    = 1,
	INVALID  = 2,
	EXISTS   = 4,
	MISSING  = 8,
	LOCAL    = 1024,
	PKGCACHE = 2048,
	GRPCACHE = 4096,
}

Db_Operations :: struct {
	validate:   proc "c" (^Db) -> i32,
	populate:   proc "c" (^Db) -> i32,
	unregister: proc "c" (^Db),
}

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/* db.c, database general calls */
	_alpm_db_new            :: proc(treename: cstring, is_local: i32) -> ^Db ---
	_alpm_db_free           :: proc(db: ^Db) ---
	_alpm_db_path           :: proc(db: ^Db) -> cstring ---
	_alpm_db_cmp            :: proc(d1: rawptr, d2: rawptr) -> i32 ---
	_alpm_db_search         :: proc(db: ^Db, needles: ^List, ret: ^^List) -> i32 ---
	_alpm_db_register_local :: proc(handle: ^Handle) -> ^Db ---
	_alpm_db_register_sync  :: proc(handle: ^Handle, treename: cstring, level: i32) -> ^Db ---
	_alpm_db_unregister     :: proc(db: ^Db) ---

	/* be_*.c, backend specific calls */
	_alpm_local_db_prepare :: proc(db: ^Db, info: ^Pkg) -> i32 ---
	_alpm_local_db_write   :: proc(db: ^Db, info: ^Pkg, inforeq: i32) -> i32 ---
	_alpm_local_db_remove  :: proc(db: ^Db, info: ^Pkg) -> i32 ---
	_alpm_local_db_pkgpath :: proc(db: ^Db, info: ^Pkg, filename: cstring) -> cstring ---

	/* cache bullshit */
	/* packages */
	_alpm_db_free_pkgcache       :: proc(db: ^Db) ---
	_alpm_db_add_pkgincache      :: proc(db: ^Db, pkg: ^Pkg) -> i32 ---
	_alpm_db_remove_pkgfromcache :: proc(db: ^Db, pkg: ^Pkg) -> i32 ---
	_alpm_db_get_pkgcache_hash   :: proc(db: ^Db) -> ^Pkghash ---
	_alpm_db_get_pkgcache        :: proc(db: ^Db) -> ^List ---
	_alpm_db_get_pkgfromcache    :: proc(db: ^Db, target: cstring) -> ^Pkg ---

	/* groups */
	_alpm_db_get_groupcache     :: proc(db: ^Db) -> ^List ---
	_alpm_db_get_groupfromcache :: proc(db: ^Db, target: cstring) -> ^Group ---
}

