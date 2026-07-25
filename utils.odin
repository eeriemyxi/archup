package main

import "core:fmt"
import "core:log"
import "core:strconv"

sec_to_micro :: #force_inline proc(n: u64) -> u64 {
	return n * 1000 * 1000
}

twrite_uint :: proc(n: u64, base: int) -> string {
	buf: [64]byte
	return fmt.tprint(strconv.write_uint(buf[:], n, base))
}

dbg :: proc(value: $T, name := #caller_expression(value)) -> T {
	log.debug(name, ": ", value, sep = "")
	return value
}
