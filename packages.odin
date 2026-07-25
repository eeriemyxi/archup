package main

import "./alpm-auto/alpm"
import "./pacutils/pacutils"
import alpm_custom "alpm"
import "core:c/libc"
import "core:fmt"
import "core:log"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:sys/linux"
import "core:text/regex"

Package :: struct {
	name:         string,
	prev_version: string,
	next_version: string,
	dl_size:      i64,
}

get_updates_super_old :: proc() -> (packages: [dynamic]Package, err: Error) {
	r, w, pierr := os.pipe()
	defer os.close(r)

	if pierr != nil do return nil, AppError{.Internal_Error, "couldn't create os pipe"}

	handle, pserr := os.process_start({command = {"checkupdates", "--nocolor"}, stdout = w})
	state, pwerr := os.process_wait(handle)
	os.close(w)

	raw_data, rerr := os.read_entire_file(r, context.temp_allocator)
	data := cast(string)raw_data

	iter, reerr := regex.create_iterator(data, `(\S+) (\S+) -> (\S+)`, flags = {.Multiline})

	for capt, index in regex.match_iterator(&iter) {
		pkg := Package {
			name         = capt.groups[1],
			prev_version = capt.groups[2],
			next_version = capt.groups[3],
		}
		append(&packages, pkg)
	}

	return
}

get_updates_old :: proc(sync: bool = true) -> (packages: [dynamic]Package, err: Error) {
	if sync {
		sync_updates_old() or_return
	}
	aerr: alpm_custom.Errno
	dbpath := get_alpm_db_path()

	if err := os.mkdir(dbpath); err != nil && err != .Exist {
		return packages, AppError {
			.Internal_Error,
			fmt.tprint("Couldn't make dir:", dbpath, "due to:", err),
		}
	}

	handle := alpm_custom.initialize(cstring("/"), strings.unsafe_string_to_cstring(dbpath), &aerr)

	if aerr != .OK {
		return packages, AppError {
			.Internal_Error,
			fmt.tprintf("Couldn't initialize alpm: %v", aerr),
		}
	}

	db_local := alpm_custom.get_localdb(handle)

	entries := os.read_all_directory_by_path(
		filepath.join({dbpath, "sync/"}) or_return,
		context.temp_allocator,
	) or_return
	for entry in entries {
		if os.ext(entry.name) != ".sig" {
			repo_name := strings.clone_to_cstring(
				os.short_stem(entry.name),
				context.temp_allocator,
			)

			db := alpm_custom.register_syncdb(handle, repo_name, 0)
			if db == nil {
				return packages, AppError {
					.Internal_Error,
					fmt.tprint("Couldn't register", repo_name),
				}
			}
		}
	}

	sync_dbs := alpm_custom.get_syncdbs(handle)

	for i := alpm_custom.db_get_pkgcache(db_local); i != nil; i = i.next {
		lpkg := cast(alpm_custom.Pkg)i.data
		name := alpm_custom.pkg_get_name(lpkg)
		npkg := alpm_custom.find_dbs_satisfier(handle, sync_dbs, name)
		if npkg != nil {
			old_ver := alpm_custom.pkg_get_version(lpkg)
			new_ver := alpm_custom.pkg_get_version(npkg)

			if alpm_custom.pkg_vercmp(new_ver, old_ver) > 0 {
				size := cast(i64)alpm_custom.pkg_download_size(npkg)
				append(&packages, Package{string(name), string(old_ver), string(new_ver), size})
			}
		}
	}

	return packages, nil
}

sync_updates_old :: proc() -> Error {
	r, w := os.pipe() or_return
	defer os.close(r)
	defer os.close(w)

	db_path := get_alpm_db_path()
	log.debug("db_path:", db_path)

	env: []string = {fmt.tprintf("CHECKUPDATES_DB=%v", db_path)}
	log.debug("env:", env)

	handle, pserr := os.process_start({command = {"checkupdates", "--nocolor"}, env = env})
	state, pwerr := os.process_wait(handle)

	if !state.success {
		return AppError {
			.Internal_Error,
			fmt.tprintf("checkupdates returned exit code %v", state.exit_code),
		}
	}

	return nil
}

display_packages :: proc(packages: ^[dynamic]Package) {
	longest: [3]int
	for pkg in packages {
		longest[0] = max(longest[0], len(pkg.name))
		longest[1] = max(longest[1], len(pkg.prev_version))
		longest[2] = max(longest[2], len(pkg.next_version))
	}

	indent := "   "

	fmt.printf("\n%v* ", indent)
	fmt.println(underline(bold("Packages that will be upgraded:\n")))

	total_bytes: i64

	for pkg in packages {
		name, errna := strings.left_justify(pkg.name, longest[0], " ", context.temp_allocator)
		prevv, errpr := strings.left_justify(
			pkg.prev_version,
			longest[1],
			" ",
			context.temp_allocator,
		)
		nextv, errne := strings.left_justify(
			pkg.next_version,
			longest[2],
			" ",
			context.temp_allocator,
		)
		fmt.print(indent)
		fmt.println(fmt.tprint(bold(fblue(name)), bold(fred(prevv)), bold(fgreen(nextv))))
		total_bytes += pkg.dl_size
	}

	KBs := total_bytes / 1024
	MBs := KBs / 1024

	fmt.print("\n", indent, sep = "")
	fmt.println(bold("Total Download Size: "), KBs, " KB", " (or ", MBs, " MB)", sep = "")
	fmt.println()
}

get_alpm_db_path :: proc() -> string {
	dbpath := fmt.tprintf(
		"%v/%v-db-%v/",
		os.temp_directory(context.temp_allocator) or_else "/tmp",
		"archup",
		linux.getuid(),
	)
	return dbpath
}

get_pacman_config :: proc() -> (config: ^pacutils.Config, err: Error) {
	config = pacutils.config_new()
	config = pacutils.ui_config_load(config, "/etc/pacman.conf")
	if config == nil {
		return config, AppError {
			.Internal_Error,
			"couldn't load configuration file at /etc/pacman.conf",
		}
	}
	return
}

get_updates :: proc(sync: bool = true) -> (packages: [dynamic]Package, err: Error) {
	dbpath := get_alpm_db_path()
	mderr := os.mkdir(dbpath)
	if mderr != nil && mderr != .Exist {
		return packages, mderr
	}

	lock_path := fmt.tprintf("%s/db.lck", dbpath)
	if os.exists(lock_path) do os.remove(lock_path)

	config := get_pacman_config() or_return
	defer pacutils.config_free(config)
	log.debug("config =", config)

	sys_dbpath, cfcerr := strings.clone_from_cstring(config.dbpath, context.temp_allocator)
	log.debug("sys_dbpath =", sys_dbpath)
	assert(cfcerr == nil, "cloning string failed, probably purchase RAM")

	{
		c_mem := libc.malloc(len(dbpath) + 1)
		([^]u8)(c_mem)[len(dbpath)] = 0 // ensure null-byte
		libc.memmove(c_mem, raw_data(dbpath), len(dbpath))

		libc.free(rawptr(config.dbpath)) // free the prev dbpath allocated by pacutils
		config.dbpath = cast(cstring)c_mem

		old := fmt.tprintf("%s/%s", sys_dbpath, "local")
		new := fmt.tprintf("%s%s", dbpath, "local")
		err := os.symlink(old, new)
		if err != nil && err != .Exist {
			return packages, AppError {
				.Internal_Error,
				fmt.tprintf("Couldn't symlink %s to %s because %v", old, new, err),
			}
		}
		log.debug("symlinked", old, "to", new)
	}

	handle := pacutils.initialize_handle_from_config(config)
	defer alpm.release(handle)

	sync_dbs := pacutils.register_syncdbs(handle, config.repos)

	if sync {
		alpm.db_update(handle, sync_dbs, cast(i32)true)
		log.debug("completed syncing")
	}

	db_local := alpm.get_localdb(handle)
	log.debug("db_local =", db_local)

	for i := alpm.db_get_pkgcache(db_local); i != nil; i = i.next {
		lpkg := cast(^alpm.Pkg)i.data
		name := alpm.pkg_get_name(lpkg)

		// It is possible to use alpm.find_dbs_satisfier(handle, sync_dbs, name)
		// but it messes up priorities. We use the following algo where we stop
		// looking after first find.
		npkg: ^alpm.Pkg = nil
		for db_node := sync_dbs; db_node != nil; db_node = db_node.next {
			db := cast(^alpm.Db)db_node.data
			if found := alpm.db_get_pkg(db, name); found != nil {
				npkg = found
				break
			}
		}

		if npkg != nil {
			old_ver := alpm.pkg_get_version(lpkg)
			new_ver := alpm.pkg_get_version(npkg)

			if alpm.pkg_vercmp(new_ver, old_ver) > 0 {
				size := cast(i64)alpm.pkg_download_size(npkg)
				append(
					&packages,
					Package {
						strings.clone_from_cstring(name),
						strings.clone_from_cstring(old_ver),
						strings.clone_from_cstring(new_ver),
						size,
					},
				)
			}
		}
	}
	return
}

free_packages :: proc(packages: [dynamic]Package) {
	for pkg in packages {
		delete(pkg.name)
		delete(pkg.next_version)
		delete(pkg.prev_version)
	}
	delete(packages)
}
