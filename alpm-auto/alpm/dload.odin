/*
 *  dload.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
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

import "core:c"
import "core:sys/posix"

foreign import lib "system:alpm"
_ :: lib

import "core:c/libc"
import "core:sys/linux"


Dload_Payload :: struct {
	handle:            ^Handle,
	tempfile_openmode: cstring,

	/* name of the remote file */
	remote_name: cstring,

	/* temporary file name, to which the payload is downloaded */
	tempfile_name: cstring,

	/* name to which the downloaded file will be renamed */
	destfile_name: cstring,

	/* client has to provide either
	*  1) fileurl - full URL to the file
	*  2) pair of (servers, filepath), in this case ALPM iterates over the
	*     server list and tries to download "$server/$filepath"
	*/
	fileurl:       cstring,
	filepath:      cstring, /* download URL path */
	cache_servers: ^List,
	servers:       ^List,
	respcode:      c.long,

	/* the mtime of the existing version of this file, if there is one */
	mtime_existing_file: c.long,
	initial_size:        posix.off_t,
	max_size:            posix.off_t,
	prevprogress:        posix.off_t,
	force:               i32,
	allow_resume:        i32,
	errors_ok:           i32,
	unlink_on_fail:      i32,
	download_signature:  i32,   /* specifies if an accompanion *.sig file need to be downloaded*/
	signature_optional:  i32,   /* *.sig file is optional */
	localf: ^libc.FILE, /* temp download file */
}

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_dload_payload_reset :: proc(payload: ^Dload_Payload) ---
	_alpm_download            :: proc(handle: ^Handle, payloads: ^List /* struct dload_payload */, localpath: cstring, temporary_localpath: cstring) -> i32 ---
}

