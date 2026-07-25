package sdevent
foreign import sdevent "system:systemd"
import "core:sys/linux"
import "core:sys/posix"

State :: enum i32 {
	OFF     = 0,
	ON      = 1,
	ONESHOT = -1,
}

Priority :: enum i32 {
	IMPORTANT = -100,
	NORMAL    = 0,
	IDLE      = 100,
}

Event :: distinct rawptr
Event_Source :: distinct rawptr
Event_IO_Handler :: #type proc "system" (
	event_source: Event_Source,
	fd: int,
	revents: u32,
	userdata: rawptr,
)
Event_Inotify_Handler :: #type proc "system" (
	event_source: Event_Source,
	inotify_event: rawptr,
	userdata: rawptr,
) -> i32
Event_Time_Handler :: #type proc "system" (event_source: Event_Source, usec: u64, userdata: rawptr) -> i32

@(link_prefix = "sd_event_")
@(default_calling_convention = "system")
foreign sdevent {
	default :: proc(ret: ^Event) -> i32 ---
	loop :: proc(e: Event) -> i32 ---
	exit :: proc(e: Event, code: i32) -> i32 ---
	now :: proc(e: Event, clock: posix.clockid_t, ret_usec: ^u64) -> i32 ---

	add_io :: proc(e: Event, ret_source: ^Event_Source, fd: i32, events: u32, callback: Event_IO_Handler, userdata: rawptr) -> i32 ---
	add_inotify :: proc(e: Event, ret_source: ^Event_Source, path: cstring, mask: bit_set[linux.Inotify_Event_Bits;u32], callback: Event_Inotify_Handler, userdata: rawptr) -> i32 ---
	add_time :: proc(e: Event, ret_source: ^Event_Source, clock: posix.clockid_t, usec: u64, accuracy: u64, callback: Event_Time_Handler, userdata: rawptr) -> i32 ---

	source_set_time :: proc(s: Event_Source, usec: u64) -> i32 ---
	source_set_enabled :: proc(s: Event_Source, enable: State) -> i32 ---

	unref :: proc(e: Event) -> Event ---
	source_unref :: proc(s: Event_Source) -> Event_Source ---
}
