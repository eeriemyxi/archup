package main

import "core:os"
import "core:slice"

join_prefix :: proc(prefix: []string, args: []string) -> [dynamic]string {
	cmd := slice.clone_to_dynamic(prefix)
	append(&cmd, ..args)
	return cmd
}

open_terminal :: proc(cmd: []string, wait: bool = true) -> (err: Error) {
	handle := os.process_start({command = cmd}) or_return
	if wait {
		_ = os.process_wait(handle) or_return
	}
	return nil
}
