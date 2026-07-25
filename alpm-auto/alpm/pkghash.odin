/*
 *  pkghash.h
 *
 *  Copyright (c) 2011-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
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


/**
* @brief A hash table for holding alpm_pkg_t objects.
*
* A combination of a hash table and a list, allowing for fast look-up
* by package name but also iteration over the packages.
*/
_Alpm_Pkghash :: struct {
	/** data held by the hash table */
	hash_table: ^^List,

	/** head node of the hash table data in normal list format */
	list: ^List,

	/** number of buckets in hash table */
	buckets: u32,

	/** number of entries in hash table */
	entries: u32,

	/** max number of entries before a resize is needed */
	limit: u32,
}

Pkghash :: _Alpm_Pkghash

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_pkghash_create     :: proc(size: u32) -> ^Pkghash ---
	_alpm_pkghash_add        :: proc(hash: ^^Pkghash, pkg: ^Pkg) -> ^Pkghash ---
	_alpm_pkghash_add_sorted :: proc(hash: ^^Pkghash, pkg: ^Pkg) -> ^Pkghash ---
	_alpm_pkghash_remove     :: proc(hash: ^Pkghash, pkg: ^Pkg, data: ^^Pkg) -> ^Pkghash ---
	_alpm_pkghash_free       :: proc(hash: ^Pkghash) ---
	_alpm_pkghash_find       :: proc(hash: ^Pkghash, name: cstring) -> ^Pkg ---
}

