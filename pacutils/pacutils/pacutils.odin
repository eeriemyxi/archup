/*
 * Copyright 2012-2016 Andrew Gregory <andrew.gregory.8@gmail.com>
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
	version                :: proc() -> cstring ---
	print_version          :: proc(progname: cstring, progver: cstring) ---
	pathcmp                :: proc(p1: cstring, p2: cstring) -> i32 ---
	filelist_contains_path :: proc(files: ^alpm.Filelist, path: cstring) -> ^alpm.File ---
	find_pkgspec           :: proc(handle: ^alpm.Handle, pkgspec: cstring) -> ^alpm.Pkg ---
	fprint_pkgspec         :: proc(stream: ^libc.FILE, pkg: ^alpm.Pkg) -> i32 ---
	pkgspec                :: proc(pkg: ^alpm.Pkg) -> cstring ---
	log_command            :: proc(handle: ^alpm.Handle, caller: cstring, argc: i32, argv: ^cstring) -> i32 ---
}

