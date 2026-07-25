/*
 * Copyright 2013-2016 Andrew Gregory <andrew.gregory.8@gmail.com>
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


Log_Operation :: enum u32 {
	INSTALL   = 0,
	REINSTALL = 1,
	UPGRADE   = 2,
	DOWNGRADE = 3,
	REMOVE    = 4,
}

Log_Action :: struct {
	operation:   Log_Operation,
	target:      cstring,
	old_version: cstring,
	new_version: cstring,
}

Log_Timestamp :: struct {
	tm: libc.tm,
	gmtoff:      i32,
	has_seconds: u32,
	has_gmtoff:  u32,
}

Log_Entry :: struct {
	timestamp: Log_Timestamp,
	caller:    cstring,
	message:   cstring,
}

Log_Transaction_Status :: enum u32 {
	STARTED     = 1,
	COMPLETED   = 2,
	INTERRUPTED = 3,
	FAILED      = 4,
}

Log_Transaction :: struct {
	status:     Log_Transaction_Status,
	start, end: ^alpm.List,
}

Log_Reader :: struct {
	stream: ^libc.FILE,
	eof:           i32,
	_buf:          [256]i8, /* read buffer */
	_next:         cstring, /* next line indicator */
	_close_stream: i32,     /* close stream on free */
	_next_ts:      Log_Timestamp,
}

@(default_calling_convention="c", link_prefix="pu_")
foreign lib {
	log_transaction_parse  :: proc(message: cstring) -> Log_Transaction_Status ---
	log_fprint_entry       :: proc(stream: ^libc.FILE, entry: ^Log_Entry) -> i32 ---
	log_reader_next        :: proc(reader: ^Log_Reader) -> ^Log_Entry ---
	log_reader_open_stream :: proc(stream: ^libc.FILE) -> ^Log_Reader ---
	log_reader_open_file   :: proc(path: cstring) -> ^Log_Reader ---
	log_reader_free        :: proc(p: ^Log_Reader) ---
	log_parse_file         :: proc(stream: ^libc.FILE) -> ^alpm.List ---
	log_entry_free         :: proc(entry: ^Log_Entry) ---
	log_action_parse       :: proc(message: cstring) -> ^Log_Action ---
	log_action_free        :: proc(action: ^Log_Action) ---
}

