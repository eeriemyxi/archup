/*
 * Copyright 2012-2020 Andrew Gregory <andrew.gregory.8@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
package pacutils

foreign import lib "system:pacutils"
_ :: lib

import "core:c/libc"
import "../../alpm-auto/alpm"
import "core:sys/linux"


@(default_calling_convention="c", link_prefix="pu_")
foreign lib {
	provision_satisfies_dep    :: proc(provision: ^alpm.Depend, dep: ^alpm.Depend) -> i32 ---
	pkg_satisfies_dep          :: proc(pkg: ^alpm.Pkg, dep: ^alpm.Depend) -> i32 ---
	pkg_depends_on             :: proc(pkg: ^alpm.Pkg, dpkg: ^alpm.Pkg) -> i32 ---
	pkg_optdepends_on          :: proc(pkg: ^alpm.Pkg, dpkg: ^alpm.Pkg) -> i32 ---
	pkg_checkdepends_on        :: proc(pkg: ^alpm.Pkg, dpkg: ^alpm.Pkg) -> i32 ---
	pkg_makedepends_on         :: proc(pkg: ^alpm.Pkg, dpkg: ^alpm.Pkg) -> i32 ---
	pkg_find_requiredby        :: proc(pkg: ^alpm.Pkg, pkgs: ^alpm.List, ret: ^^alpm.List) -> i32 ---
	pkg_find_optionalfor       :: proc(pkg: ^alpm.Pkg, pkgs: ^alpm.List, ret: ^^alpm.List) -> i32 ---
	pkg_find_makedepfor        :: proc(pkg: ^alpm.Pkg, pkgs: ^alpm.List, ret: ^^alpm.List) -> i32 ---
	pkg_find_checkdepfor       :: proc(pkg: ^alpm.Pkg, pkgs: ^alpm.List, ret: ^^alpm.List) -> i32 ---
	pkglist_find_dep_satisfier :: proc(pkgs: ^alpm.List, dep: ^alpm.Depend) -> ^alpm.Pkg ---
	db_find_dep_satisfier      :: proc(db: ^alpm.Db, dep: ^alpm.Depend) -> ^alpm.Pkg ---
	dblist_find_dep_satisfier  :: proc(dbs: ^alpm.List, dep: ^alpm.Depend) -> ^alpm.Pkg ---
}

