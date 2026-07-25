package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:terminal/ansi"

AppErrorType :: enum {
	Invalid_Config_File,
	Required_Field_Missing,
	Required_Field_Invalid,
	Database_Error,
	Notification_Error,
	Internal_Error,
}

AppError :: struct {
	type: AppErrorType,
	msg:  string,
}

LuaError :: struct {
	status: i32,
	msg:    string,
}

Error :: union {
	AppError,
	LuaError,
	os.Error,
	runtime.Allocator_Error,
}

pprint_info :: proc(msg: string = "", args: ..any) {
	indent := "   "
	fmt.printf("\n%v%v", indent, fblue(bold(fmt.tprint("[!]", underline("INFO\n")))))
	fmt.println()
	fmt.print(indent)
	kv_print_c(ansi.FG_BRIGHT_BLUE, "Message", ansi.FG_WHITE, fmt.tprintf(msg, ..args))
	fmt.println()
}

pprint_warning :: proc(
	msg: string = "",
	args: ..any,
	loc := #caller_location,
	expr := #caller_expression,
) {
	indent := "   "
	fmt.printf("\n%v%v", indent, fyellow(bold(fmt.tprint("[!]", underline("WARNING\n")))))
	fmt.println()
	fmt.print(indent)
	kv_print_c(ansi.FG_BRIGHT_YELLOW, "Message", ansi.FG_WHITE, fmt.tprintf(msg, ..args))
	fmt.println()
}

pprint_error :: proc(
	err: Error,
	msg: string = "",
	args: ..any,
	loc := #caller_location,
	expr := #caller_expression,
) {
	msg := fmt.tprintf(msg, ..args)
	indent := "   "

	fmt.printf("\n%v%v", indent, fred(bold(fmt.tprint("[!]", underline("ERROR\n")))))
	fmt.println()
	#partial switch e in err {
	case AppError:
		fmt.print(indent)
		kv_print_c(ansi.FG_BRIGHT_RED, "Type", ansi.FG_WHITE, e.type)
		fmt.print(indent)
		kv_print_c(ansi.FG_BRIGHT_RED, "Message", ansi.FG_WHITE, e.msg)
		if len(msg) > 0 {
			fmt.print(indent)
			kv_print_c(ansi.FG_BRIGHT_RED, "Extra Message", ansi.FG_WHITE, msg)
		}
	case LuaError:
		fmt.print(indent)
		kv_print_c(ansi.FG_BRIGHT_RED, "Status", ansi.FG_WHITE, e.status)
		fmt.print(indent)
		kv_print_c(ansi.FG_BRIGHT_RED, "Message", ansi.FG_WHITE, e.msg)
		if len(msg) > 0 {
			fmt.print(indent)
			kv_print_c(ansi.FG_BRIGHT_RED, "Extra Message", ansi.FG_WHITE, msg)
		}
	case:
		if err != nil {
			fmt.print(indent)
			kv_print_c(ansi.FG_BRIGHT_RED, "Status", ansi.FG_WHITE, e)
		}
		if len(msg) > 0 {
			fmt.print(indent)
			kv_print_c(ansi.FG_BRIGHT_RED, "Message", ansi.FG_WHITE, msg)
		}
	}

	if err != nil {
		fmt.println("\n", loc, ":", loc.procedure, ":", expr, sep = "")
	} else {
		fmt.println()
	}
}
