/*
 *  signing.h
 *
 *  Copyright (c) 2008-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
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
	_alpm_sigpath          :: proc(handle: ^Handle, path: cstring) -> cstring ---
	_alpm_gpgme_checksig   :: proc(handle: ^Handle, path: cstring, base64_sig: cstring, result: ^Siglist) -> i32 ---
	_alpm_check_pgp_helper :: proc(handle: ^Handle, path: cstring, base64_sig: cstring, optional: i32, marginal: i32, unknown: i32, sigdata: ^^Siglist) -> i32 ---
	_alpm_process_siglist  :: proc(handle: ^Handle, identifier: cstring, siglist: ^Siglist, optional: i32, marginal: i32, unknown: i32) -> i32 ---
	_alpm_key_in_keychain  :: proc(handle: ^Handle, fpr: cstring) -> i32 ---
	_alpm_key_import       :: proc(handle: ^Handle, uid: cstring, fpr: cstring) -> i32 ---
}

