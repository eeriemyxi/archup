#+feature dynamic-literals

package main

import "./ext/sqlite/"
import "./pacutils/pacutils"
import "base:runtime"
import "core:flags"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "core:strings"

@(private = "file")
Options :: struct {
	command:   string `args:"pos=0" usage:"Name of the command."`,
	log_level: log.Level `usage:"Set log level. Info by default. Options: Debug, Info, Warning, Error, Fatal"`, // I can't figure out how to set alias
	nosync:    bool `usage:"Don't sync packages. Only for update subcommand."`,
	_cmds:     Cmds_Type `args:"hidden"`,
	_cmd:      #type proc(_: ^Options) `args:"hidden"`,
}

@(private = "file")
Cmds_Type :: map[string]struct {
	func: #type proc(_: ^Options),
	desc: string,
}

update_cmd :: proc(args: ^Options) {
	content, gcerr := get_config_file(context.temp_allocator)
	if gcerr != nil {
		pprint_error(
			gcerr,
			fmt.tprintf("Couldn't find config file at %v", get_config_path() or_else "nil"),
		)
		os.exit(1)
	}
	config, pcerr := parse_config_file(content)
	if pcerr != nil {
		pprint_error(pcerr, "Couldn't parse config file at %v", get_config_path() or_else "nil")
		os.exit(1)
	}
	defer free_config(&config)

	packages, err := get_updates(sync = false if args.nosync else true)
	if err != nil {
		pprint_error(err)
		os.exit(1)
	}
	defer free_packages(packages)

	display_packages(&packages)

	answer_buf: [16]byte
	fmt.print("Do you wish to continue (upgrading your system)? (Y/n) ")
	n, orerr := os.read(os.stdin, answer_buf[:])
	if orerr != nil {
		fmt.eprintln("Error reading: ", orerr)
		return
	}

	answer := strings.to_lower(strings.trim_space(string(answer_buf[:n])))
	defer delete(answer)

	if answer != "y" && len(answer) != 0 {
		fmt.println("OK. Have a good day!")
		return
	}

	log.debug("pacman config =", config.pacman_config_content)

	f, ctferr := os.create_temp_file("", "archup_pacman_config")
	assert(ctferr == nil, "couldn't create temp file")

	tp_config_path := strings.clone(os.name(f))
	defer delete(tp_config_path)

	os.write(f, transmute([]u8)config.pacman_config_content)
	os.close(f)

	defer os.remove(tp_config_path)

	pac_config, gpcerr := get_pacman_config()
	if gpcerr != nil {
		pprint_error(gpcerr, "couldn't parse pacman config file")
	}
	defer pacutils.config_free(pac_config)

	cmd := fmt.tprintf(
		`sudo rm -rf '{1:s}/.archup.sync.bk';
		 [ -d '{1:s}/sync' ] && sudo mv -f '{1:s}/sync/' '{1:s}/.archup.sync.bk/';
		 sudo cp -aT '{0:s}/sync/' '{1:s}/sync/' \
		 && sudo pacman --config '{2:s}' -Su;
		 echo; read -p 'Press Enter to exit...'`,
		get_alpm_db_path(),
		pac_config.dbpath,
		tp_config_path,
	)
	log.debug("cmd =", cmd)

	handle, pserr := os.process_start(
		{command = {"sh", "-c", cmd}, stdout = os.stdout, stdin = os.stdin, stderr = os.stderr},
	)

	if pserr != nil {
		pprint_error(pserr, "error while trying to start process")
		os.exit(1)
	}

	state, pwerr := os.process_wait(handle)

	if pwerr != nil {
		pprint_error(pwerr, "error while waiting for process to finish")
		os.exit(1)
	}
}

daemon_cmd :: proc(args: ^Options) {
	content, gcerr := get_config_file(context.temp_allocator)
	if gcerr != nil {
		pprint_error(
			gcerr,
			fmt.tprintf("Couldn't find config file at %v", get_config_path() or_else "nil"),
		)
		os.exit(1)
	}

	config, pcerr := parse_config_file(content)
	if pcerr != nil {
		pprint_error(pcerr, "Couldn't parse config file at %v", get_config_path() or_else "nil")
		os.exit(1)
	}
	defer free_config(&config)

	log.debug("config =", config)

	db: ^sqlite.Connection
	if err := open_db(&db); err != nil {
		pprint_error(err)
		os.exit(1)
	}
	defer sqlite.close(db)

	if err := migrate(db); err != nil {
		pprint_error(err)
		os.exit(1)
	}

	config_path, cderr := get_config_path(context.temp_allocator)
	assert(cderr == nil, "Not possible")
	event_loop(db, &config, config_path)
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	show_cmds :: proc(cmds: Cmds_Type) {
		indent := "   "
		fmt.printf("%v%v\n\n", indent, fblue(bold("[?] HELP")))
		fmt.printf("%v* %v\n\n", indent, bold(underline("Available commands:")))
		for key, val in cmds {
			fmt.print(indent, "  ", sep = "")
			kv_print(key, val.desc)
		}
	}

	flag_checker :: proc(
		model: rawptr,
		name: string,
		value: any,
		args_tag: string,
	) -> (
		error: string,
	) {
		model := cast(^Options)model
		if name == "command" {
			switch v in value {
			case string:
				if v in model._cmds {
					model._cmd = model._cmds[v].func
				} else {
					pprint_error(nil, "The provided command '%v' doesn't exist.", v)
					show_cmds(model._cmds)
					fmt.println()
					os.exit(1)
				}
			}
		}
		return
	}

	flags.register_flag_checker(flag_checker)

	opt: Options
	opt.log_level = .Info
	opt._cmds = {
		"update" = {update_cmd, "Update your system"},
		"loop"   = {daemon_cmd, "Start the daemon"},
	}
	defer delete(opt._cmds)

	flags.parse_or_exit(&opt, os.args)

	if len(opt.command) == 0 {
		pprint_error(nil, "No command was provided.")
		show_cmds(opt._cmds)
		fmt.println()
		os.exit(1)
	}

	context.logger.lowest_level = opt.log_level

	if opt._cmd != nil {
		opt._cmd(&opt)
	}

	free_all(context.temp_allocator)
}
