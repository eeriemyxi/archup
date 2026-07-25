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

import "core:c"

foreign import lib "system:pacutils"
_ :: lib

import "core:c/libc"
import "../../alpm-auto/alpm"
import "core:sys/linux"


Ui_Ctx_Download :: struct {
	/* settings */
	
	/* FILE to write to */
	out: ^libc.FILE,

	/* how frequently to update the current download (ms),
	* setting too low a value can cause flickering */
	update_interval_same: u64,

	/* how frequently to advance to the next download (ms),
	* setting too low a value can cause flickering */
	update_interval_next: u64,

	/* context */
	last_update:      u64,
	last_advance:     u64,
	active_downloads: ^alpm.List,
	index:            i32,
}

@(default_calling_convention="c", link_prefix="pu_")
foreign lib {
	ui_error                 :: proc(fmt: cstring, #c_vararg _: ..any) ---
	ui_warn                  :: proc(fmt: cstring, #c_vararg _: ..any) ---
	ui_notice                :: proc(fmt: cstring, #c_vararg _: ..any) ---
	ui_verror                :: proc(fmt: cstring, args: c.va_list) ---
	ui_vwarn                 :: proc(fmt: cstring, args: c.va_list) ---
	ui_vnotice               :: proc(fmt: cstring, args: c.va_list) ---
	ui_confirm               :: proc(def: i32, prompt: cstring, #c_vararg _: ..any) -> i32 ---
	ui_select_index          :: proc(def: c.long, min: c.long, max: c.long, prompt: cstring, #c_vararg _: ..any) -> c.long ---
	ui_msg_progress          :: proc(event: ^alpm.Progress) -> cstring ---
	ui_display_transaction   :: proc(handle: ^alpm.Handle) ---
	ui_cb_download           :: proc(ctx: rawptr, filename: cstring, event: ^alpm.Download_Event_Type, data: rawptr) ---
	ui_cb_progress           :: proc(ctx: rawptr, event: ^alpm.Progress, pkgname: cstring, percent: i32, total: i32, current: i32) ---
	ui_cb_question           :: proc(ctx: rawptr, question: ^alpm.Question) ---
	ui_cb_event              :: proc(ctx: rawptr, event: ^alpm.Event) ---
	ui_config_parse          :: proc(dest: ^Config, file: cstring) -> ^Config ---
	ui_config_load           :: proc(dest: ^Config, file: cstring) -> ^Config ---
	ui_config_parse_sysroot  :: proc(dest: ^Config, file: cstring, root: cstring) -> ^Config ---
	ui_config_load_sysroot   :: proc(dest: ^Config, file: cstring, root: cstring) -> ^Config ---
	ui_read_list_from_fd     :: proc(fd: i32, sep: i32, dest: ^^alpm.List) -> i32 ---
	ui_read_list_from_fdstr  :: proc(fdstr: cstring, sep: i32, dest: ^^alpm.List) -> i32 ---
	ui_read_list_from_path   :: proc(file: cstring, sep: i32, dest: ^^alpm.List) -> i32 ---
	ui_read_list_from_stream :: proc(file: ^libc.FILE, sep: i32, dest: ^^alpm.List, name: cstring) -> i32 ---
	ui_process_std_arg       :: proc(arg: cstring, sep: i32, dest: ^^alpm.List) -> i32 ---
}

