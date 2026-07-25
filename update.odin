package main

import "core:fmt"

update_system :: proc(
	pacman_config_path: string,
	term_prefix: []string,
	dbpath: cstring,
) -> Error {
	cmd := join_prefix(
		term_prefix,
		{
			"sh",
			"-c",
			fmt.tprintf(
				"echo sudo cp -a '{0:s}sync/.' {1:s}/sync/ && echo sudo pacman --config '{2:s}' -Su; echo; read -p 'Press Enter to exit...'",
				get_alpm_db_path(),
				dbpath,
				pacman_config_path,
			),
		},
	)
	defer delete(cmd)

	open_terminal(cmd[:], wait = false) or_return

	return nil
}
