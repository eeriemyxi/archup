/*
 * Copyright 2024 Andrew Gregory <andrew.gregory.8@gmail.com>
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
	/******************************************************************************
	* Basic wrappers with error messages that exit the program on failure
	*****************************************************************************/
	uix_strdup                   :: proc(_string: cstring) -> cstring ---
	uix_malloc                   :: proc(size: i32) -> rawptr ---
	uix_calloc                   :: proc(nelem: i32, elsize: i32) -> rawptr ---
	uix_realloc                  :: proc(ptr: rawptr, size: i32) -> rawptr ---
	uix_list_append              :: proc(list: ^^alpm.List, data: rawptr) -> ^alpm.List ---
	uix_list_append_strdup       :: proc(list: ^^alpm.List, data: cstring) -> ^alpm.List ---
	uix_read_list_from_fd_string :: proc(fdstr: cstring, sep: i32, dest: ^^alpm.List) ---
	uix_read_list_from_path      :: proc(file: cstring, sep: i32, dest: ^^alpm.List) ---
	uix_read_list_from_stream    :: proc(stream: ^libc.FILE, sep: i32, dest: ^^alpm.List, label: cstring) ---
	uix_process_std_arg          :: proc(arg: cstring, sep: i32, dest: ^^alpm.List) ---
}

