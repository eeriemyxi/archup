/*
 * Copyright 2012-2015 Andrew Gregory <andrew.gregory.8@gmail.com>
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

import "core:sys/posix"

foreign import lib "system:pacutils"
_ :: lib

import "core:c/libc"
import "../../alpm-auto/alpm"
import "core:sys/linux"


Mtree :: struct {
	path:         cstring,
	type:         [16]i8,
	uid: u32,
	gid:          posix.gid_t,
	mode: u32,
	size:         posix.off_t,
	md5digest:    [33]i8,
	sha256digest: [65]i8,
}

Mtree_Reader :: struct {
	stream: ^libc.FILE,
	eof:           i32,
	defaults:      Mtree,
	_buf:          cstring, /* line buffer */
	_buflen:       i32,     /* line buffer length */
	_stream_buf:   cstring, /* buffer for in-memory streams */
	_close_stream: i32,     /* close stream on free */
}

@(default_calling_convention="c", link_prefix="pu_")
foreign lib {
	mtree_load_pkg_mtree      :: proc(handle: ^alpm.Handle, pkg: ^alpm.Pkg) -> ^alpm.List ---
	mtree_reader_open_stream  :: proc(stream: ^libc.FILE) -> ^Mtree_Reader ---
	mtree_reader_open_file    :: proc(path: cstring) -> ^Mtree_Reader ---
	mtree_reader_open_package :: proc(h: ^alpm.Handle, p: ^alpm.Pkg) -> ^Mtree_Reader ---
	mtree_reader_next         :: proc(reader: ^Mtree_Reader, dest: ^Mtree) -> ^Mtree ---
	mtree_new                 :: proc() -> ^Mtree ---
	mtree_reader_free         :: proc(reader: ^Mtree_Reader) ---
	mtree_free                :: proc(mtree: ^Mtree) ---
}

