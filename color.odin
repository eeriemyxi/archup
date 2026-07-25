package main

import "core:fmt"
import "core:terminal/ansi"

styled :: proc(style: string, text: string) -> string {
	return fmt.tprintf("\x1b[%vm%v\x1b[0m", style, text)
}

bold :: proc(text: string) -> string {
	return styled(ansi.BOLD, text)
}

underline :: proc(text: string) -> string {
	return styled(ansi.UNDERLINE, text)
}

fblue :: proc(text: string) -> string {
	return styled(ansi.FG_BRIGHT_BLUE, text)
}

fred :: proc(text: string) -> string {
	return styled(ansi.FG_BRIGHT_RED, text)
}

fgreen :: proc(text: string) -> string {
	return styled(ansi.FG_BRIGHT_GREEN, text)
}

fyellow :: proc(text: string) -> string {
	return styled(ansi.FG_BRIGHT_YELLOW, text)
}

kv_print_c :: proc(c1: string, key: string, c2: string, value: any) {
	fmt.println(bold(styled(c1, key)), "::", bold(styled(c2, fmt.tprint(value))))
}

kv_print :: proc(key: string, value: any) {
	fmt.println(bold(fblue(key)), "::", bold(fyellow(fmt.tprint(value))))
}
