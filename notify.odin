package main

import "./sdbus"
import "core:fmt"
import "core:strings"

SignalContext :: struct {
	invoked_signal: sdbus.Bus_Slot,
	closed_signal:  sdbus.Bus_Slot,
}

enable_notifications :: proc(
	bus: sdbus.Bus,
	invoked_callback: sdbus.Callback_Type,
	closed_callback: sdbus.Callback_Type,
	userdata: rawptr,
) -> (
	signals: SignalContext,
) {
	r: i32

	r = sdbus.match_signal(
		bus,
		&signals.invoked_signal,
		"org.freedesktop.Notifications",
		"/org/freedesktop/Notifications",
		"org.freedesktop.Notifications",
		"ActionInvoked",
		invoked_callback,
		userdata,
	)

	r = sdbus.match_signal(
		bus,
		&signals.closed_signal,
		"org.freedesktop.Notifications",
		"/org/freedesktop/Notifications",
		"org.freedesktop.Notifications",
		"NotificationClosed",
		closed_callback,
		userdata,
	)

	return
}

disable_notifications :: proc(signals: SignalContext) {
	sdbus.slot_unref(signals.invoked_signal)
	sdbus.slot_unref(signals.closed_signal)
}

Hint :: struct {
	code: rune,
	val:  rawptr,
}

Hints_Type :: map[string]Hint

send_notification :: proc(
	bus: sdbus.Bus,
	id: u32,
	app_name: string,
	app_icon: string,
	summary: string,
	body: string,
	actions: []string,
	hints: Hints_Type,
	expire_timeout: i32,
) -> (
	noti_id: u32,
	err: Error,
) {
	msg: sdbus.Message
	r: i32

	r = sdbus.message_new_method_call(
		bus,
		&msg,
		"org.freedesktop.Notifications",
		"/org/freedesktop/Notifications",
		"org.freedesktop.Notifications",
		"Notify",
	)

	if r < 0 do return noti_id, AppError{.Notification_Error, fmt.tprintf("Failed to send notification, return code: %v", r)}
	defer sdbus.message_unref(msg)

	app_name := strings.unsafe_string_to_cstring(app_name)
	id := id
	app_icon := strings.unsafe_string_to_cstring(app_icon)
	summary := strings.unsafe_string_to_cstring(summary)
	body := strings.unsafe_string_to_cstring(body)
	expire_timeout := i32(-1)

	sdbus.message_append_basic(msg, 's', rawptr(app_name))
	sdbus.message_append_basic(msg, 'u', &id)
	sdbus.message_append_basic(msg, 's', rawptr(app_icon))
	sdbus.message_append_basic(msg, 's', rawptr(summary))
	sdbus.message_append_basic(msg, 's', rawptr(body))

	r = sdbus.message_open_container(msg, 'a', "s")
	if r >= 0 {
		for item in actions {
			sdbus.message_append_basic(msg, 's', rawptr(strings.unsafe_string_to_cstring(item)))
		}
		sdbus.message_close_container(msg)
	} else {
		return noti_id, AppError {
			.Notification_Error,
			fmt.tprintf("Failed to construct actions array, return code: %v", r),
		}
	}

	r = sdbus.message_open_container(msg, 'a', "{sv}")
	if r >= 0 {
		for hint, val in hints {
			r = sdbus.message_open_container(msg, 'e', "sv")
			if r >= 0 {
				sdbus.message_append_basic(
					msg,
					's',
					rawptr(strings.unsafe_string_to_cstring(hint)),
				)

				sdbus.message_open_container(msg, 'v', fmt.ctprintf("%c", val.code))
				sdbus.message_append_basic(msg, cast(u8)val.code, val.val)
				sdbus.message_close_container(msg)
			}
			sdbus.message_close_container(msg)
		}
		sdbus.message_close_container(msg)
	} else {
		return noti_id, AppError {
			.Notification_Error,
			fmt.tprintf("Failed to construct hint dictionary, return code: %v", r),
		}
	}

	sdbus.message_append_basic(msg, 'i', &expire_timeout)

	reply: sdbus.Message

	r = sdbus.call(bus, msg, 0, nil, &reply)
	if r < 0 {
		return noti_id, AppError {
			.Notification_Error,
			fmt.tprintf("Failed to send notification, return code: %v", r),
		}
	}
	defer sdbus.message_unref(reply)

	r = sdbus.message_read_basic(reply, 'u', &noti_id)
	if r < 0 {
		fmt.eprintln("Failed to parse notification ID from reply:", r)
	}

	return
}
