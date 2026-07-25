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

import "core:c"
import "core:sys/posix"

foreign import lib "system:pacutils"
_ :: lib

import "core:c/libc"
import "../../alpm-auto/alpm"
import "core:sys/linux"


@(default_calling_convention="c", link_prefix="pu_")
foreign lib {
	iscspace              :: proc(_c: i32) -> i32 ---
	basename              :: proc(path: cstring) -> cstring ---
	hr_size               :: proc(bytes: posix.off_t, dest: cstring) -> cstring ---
	parse_datetime        :: proc(_string: cstring, stm: ^libc.tm) -> ^libc.tm ---
	_pu_list_shift        :: proc(list: ^^alpm.List) -> rawptr ---
	list_append_str       :: proc(list: ^^alpm.List, str: cstring) -> ^alpm.List ---
	vasprintf             :: proc(fmt: cstring, args: c.va_list) -> cstring ---
	asprintf              :: proc(fmt: cstring, #c_vararg _: ..any) -> cstring ---
	prepend_dir           :: proc(dir: cstring, path: cstring) -> cstring ---
	prepend_dir_list      :: proc(dir: cstring, paths: ^alpm.List) -> i32 ---
	fopenat               :: proc(dirfd: i32, path: cstring, mode: cstring) -> ^libc.FILE ---
	read_list_from_stream :: proc(f: ^libc.FILE, sep: i32, dest: ^^alpm.List) -> i32 ---
	read_list_from_fd     :: proc(fd: i32, sep: i32, dest: ^^alpm.List) -> i32 ---
	read_list_from_path   :: proc(path: cstring, sep: i32, dest: ^^alpm.List) -> i32 ---
}

