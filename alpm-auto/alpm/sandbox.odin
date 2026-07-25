/*
 *  sandbox.h
 *
 *  Copyright (c) 2021-2022 Pacman Development Team <pacman-dev@lists.archlinux.org>
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


/* The type of callbacks that can happen during a sandboxed operation */
_Alpm_Sandbox_Callback :: enum u32 {
	LOG      = 0,
	DOWNLOAD = 1,
}

_Alpm_Sandbox_Callback_Context :: struct {
	callback_pipe: i32,
}

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/* Sandbox callbacks */
	_alpm_sandbox_cb_log :: proc(ctx: rawptr, level: i32, fmt: cstring, args: i32) ---
	_alpm_sandbox_cb_dl  :: proc(ctx: rawptr, filename: cstring, event: i32, data: rawptr) ---

	/* Functions to capture sandbox callbacks and convert them to alpm callbacks */
	_alpm_sandbox_process_cb_log      :: proc(handle: ^i32, callback_pipe: i32) -> i32 ---
	_alpm_sandbox_process_cb_download :: proc(handle: ^i32, callback_pipe: i32) -> i32 ---
}

