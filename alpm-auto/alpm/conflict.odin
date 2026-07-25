/*
 *  conflict.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
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


@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_conflict_dup          :: proc(conflict: ^Conflict) -> ^Conflict ---
	_alpm_innerconflicts        :: proc(handle: ^Handle, packages: ^List) -> ^List ---
	_alpm_outerconflicts        :: proc(db: ^Db, packages: ^List) -> ^List ---
	_alpm_db_find_fileconflicts :: proc(handle: ^Handle, upgrade: ^List, remove: ^List) -> ^List ---
}

