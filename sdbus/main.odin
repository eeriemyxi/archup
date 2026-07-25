package sdbus

import "core:fmt"
import "core:strings"
import "../sdevent/"
foreign import sdbus "system:systemd"

Bus :: distinct rawptr
Bus_Slot :: distinct rawptr
Message_Handler :: distinct rawptr
Message :: distinct rawptr
Error :: distinct rawptr
Callback_Type :: distinct proc "system" (m: Message, userdata: rawptr, ret_error: Error) -> i32

@(link_prefix = "sd_bus_")
@(default_calling_convention = "system")
foreign sdbus {
	open_user :: proc(bus: ^Bus) -> i32 ---

	@(link_name = "sd_bus_match_signal")
	_match_signal :: proc(bus: Bus, ret: ^Bus_Slot, sender: cstring, path: cstring, interface: cstring, member: cstring, callback: Callback_Type, userdata: rawptr) -> i32 ---

	call_method :: proc(bus: Bus, destination: cstring, path: cstring, interface: cstring, member: cstring, ret_error: Error, reply: ^Message, types: cstring, #c_vararg args: ..any) -> i32 ---

	process :: proc(bus: Bus, ret: ^Message) -> i32 ---

	wait :: proc(bus: Bus, timeout_usec: u64) -> i32 ---

	attach_event :: proc(bus: Bus, e: sdevent.Event, priority: sdevent.Priority) -> i32 ---
	detach_event :: proc(bus: Bus) -> i32 ---

	flush_close_unref :: proc(bus: Bus) -> i32 ---

	@(link_name = "sd_bus_message_read")
	_message_read :: proc(m: Message, types: cstring, #c_vararg args: ..any) -> i32 ---

	message_new_method_call :: proc(bus: Bus, m: ^Message, destination: cstring, path: cstring, interface: cstring, member: cstring) -> i32 ---

	message_append_basic :: proc(m: Message, type: u8, p: rawptr) -> i32 ---

	call :: proc(bus: Bus, m: Message, usec: u64, ret_error: Error, reply: ^Message) -> i32 ---

	message_unref :: proc(m: Message) -> Message ---
	slot_unref :: proc(m: Bus_Slot) -> Bus_Slot ---

	message_open_container :: proc(m: Message, type: u8, contents: cstring) -> i32 ---

	message_close_container :: proc(m: Message) -> i32 ---

	message_read_basic :: proc(m: Message, type: u8, p: rawptr) -> i32 ---

	message_enter_container :: proc(m: Message, type: u8, contents: cstring) -> i32 ---

	message_exit_container :: proc(m: Message) -> i32 ---
}

match_signal :: proc(
	bus: Bus,
	ret: ^Bus_Slot,
	sender: string,
	path: string,
	interface: string,
	member: string,
	callback: Callback_Type,
	userdata: rawptr,
) -> i32 {
	return _match_signal(
		bus,
		ret,
		strings.unsafe_string_to_cstring(sender),
		strings.unsafe_string_to_cstring(path),
		strings.unsafe_string_to_cstring(interface),
		strings.unsafe_string_to_cstring(member),
		callback,
		userdata,
	)
}

message_read :: proc(m: Message, args: ..struct{type: rune, p: rawptr}) {
	for data in args {
		message_read_basic(m, cast(u8)data.type, data.p)
	}
}
