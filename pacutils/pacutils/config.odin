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

foreign import lib "system:pacutils"
_ :: lib

import "core:c/libc"
import "../../alpm-auto/alpm"
import "core:sys/linux"


Config_Option :: enum u32 {
	ROOTDIR                  = 0,
	DBPATH                   = 1,
	GPGDIR                   = 2,
	LOGFILE                  = 3,
	ARCHITECTURE             = 4,
	XFERCOMMAND              = 5,
	CLEANMETHOD              = 6,
	COLOR                    = 7,
	NOPROGRESSBAR            = 8,
	USESYSLOG                = 9,
	CHECKSPACE               = 10,
	VERBOSEPKGLISTS          = 11,
	ILOVECANDY               = 12,
	DISABLEDOWNLOADTIMEOUT   = 13,
	PARALLELDOWNLOADS        = 14,
	PRETTYPROGRESSBAR        = 15,
	SIGLEVEL                 = 16,
	LOCAL_SIGLEVEL           = 17,
	REMOTE_SIGLEVEL          = 18,
	HOOKDIRS                 = 19,
	HOLDPKGS                 = 20,
	IGNOREPKGS               = 21,
	IGNOREGROUPS             = 22,
	NOUPGRADE                = 23,
	NOEXTRACT                = 24,
	REPOS                    = 25,
	CACHEDIRS                = 26,
	SERVER                   = 27,
	CACHESERVER              = 28,
	USAGE                    = 29,
	DOWNLOADUSER             = 30,
	DISABLESANDBOXFILESYSTEM = 31,
	DISABLESANDBOXSYSCALLS   = 32,
	INCLUDE                  = 33,
}

/* config */
Config_Cleanmethod :: enum u32 {
	INSTALLED = 1,
	CURRENT   = 2,
}

Config_Bool :: enum i32 {
	UNSET = -1,
	FALSE = 0,
	TRUE  = 1,
}

Config :: struct {
	rootdir:                  cstring,
	dbpath:                   cstring,
	gpgdir:                   cstring,
	logfile:                  cstring,
	xfercommand:              cstring,
	downloaduser:             cstring,
	paralleldownloads:        i32,
	checkspace:               Config_Bool,
	color:                    Config_Bool,
	noprogressbar:            Config_Bool,
	ilovecandy:               Config_Bool,
	usesyslog:                Config_Bool,
	verbosepkglists:          Config_Bool,
	disabledownloadtimeout:   Config_Bool,
	disablesandboxfilesystem: Config_Bool,
	disablesandboxsyscalls:   Config_Bool,
	prettyprogressbar:        Config_Bool,
	siglevel:                 i32,
	localfilesiglevel:        i32,
	remotefilesiglevel:       i32,
	siglevel_mask:            i32,
	localfilesiglevel_mask:   i32,
	remotefilesiglevel_mask:  i32,
	architectures: ^alpm.List,
	cachedirs: ^alpm.List,
	holdpkgs: ^alpm.List,
	hookdirs: ^alpm.List,
	ignoregroups: ^alpm.List,
	ignorepkgs: ^alpm.List,
	noextract: ^alpm.List,
	noupgrade: ^alpm.List,
	cleanmethod:              i32,
	repos: ^alpm.List,
}

/* sync repos */
Repo :: struct {
	name:          cstring,
	servers: ^alpm.List,
	cacheservers: ^alpm.List,
	usage:         i32,
	siglevel:      i32,
	siglevel_mask: i32,
}

Config_Reader_Status :: enum u32 {
	OK             = 0,
	ERROR          = 1,
	INVALID_VALUE  = 2,
	UNKNOWN_OPTION = 3,
}

Config_Reader :: struct {
	eof, line, error:                   i32,
	sysroot, file, section, key, value: cstring,
	config:                             ^Config,
	repo:                               ^Repo,
	status:                             Config_Reader_Status,
	_mini:                              rawptr,
	_parent:                            ^Config_Reader,
	_includes: ^alpm.List,
	_sysroot_fd:                        i32,
}

@(default_calling_convention="c", link_prefix="pu_")
foreign lib {
	repo_new                      :: proc() -> ^Repo ---
	repo_free                     :: proc(repo: ^Repo) ---
	register_syncdb               :: proc(handle: ^alpm.Handle, repo: ^Repo) -> ^alpm.Db ---
	register_syncdbs              :: proc(handle: ^alpm.Handle, repos: ^alpm.List) -> ^alpm.List ---
	config_new                    :: proc() -> ^Config ---
	config_merge                  :: proc(dest: ^Config, src: ^Config) ---
	config_resolve                :: proc(config: ^Config) -> i32 ---
	config_resolve_sysroot        :: proc(config: ^Config, sysroot: cstring) -> i32 ---
	config_free                   :: proc(config: ^Config) ---
	initialize_handle_from_config :: proc(config: ^Config) -> ^alpm.Handle ---
	config_reader_new_sysroot     :: proc(config: ^Config, file: cstring, sysroot: cstring) -> ^Config_Reader ---
	config_reader_new             :: proc(config: ^Config, file: cstring) -> ^Config_Reader ---
	config_reader_finit           :: proc(config: ^Config, stream: ^libc.FILE) -> ^Config_Reader ---
	config_reader_next            :: proc(reader: ^Config_Reader) -> i32 ---
	config_reader_free            :: proc(reader: ^Config_Reader) ---
}

