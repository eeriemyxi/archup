/*
 *  deps.h
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


@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_dep_dup         :: proc(dep: ^Depend) -> ^Depend ---
	_alpm_sortbydeps      :: proc(handle: ^Handle, targets: ^List, ignore: ^List, reverse: i32) -> ^List ---
	_alpm_recursedeps     :: proc(db: ^Db, targs: ^^List, include_explicit: i32) -> i32 ---
	_alpm_resolvedeps     :: proc(handle: ^Handle, localpkgs: ^List, pkg: ^Pkg, preferred: ^List, packages: ^^List, remove: ^List, data: ^^List) -> i32 ---
	_alpm_depcmp_literal  :: proc(pkg: ^Pkg, dep: ^Depend) -> i32 ---
	_alpm_depcmp_provides :: proc(dep: ^Depend, provisions: ^List) -> i32 ---
	_alpm_depcmp          :: proc(pkg: ^Pkg, dep: ^Depend) -> i32 ---
}

