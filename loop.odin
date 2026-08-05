package main

import "./ext/sqlite/"
import "./sdbus/"
import "./sdevent/"

import "core:log"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:sys/linux"
import "core:time"

import "base:runtime"
import "core:fmt"
import "core:sys/posix"

EventContext :: struct {
	db:                  ^sqlite.Connection,
	config_path:         string,
	bus:                 sdbus.Bus,
	event:               sdevent.Event,
	noti_id:             u32,
	debounce_evt_source: sdevent.Event_Source,
	time_evt_source:     sdevent.Event_Source,
	intervals_reached:   u32,
}

runtime_context: runtime.Context
config_checker_last: time.Time = time.now()

on_action_closed :: proc "c" (m: sdbus.Message, userdata: rawptr, err: sdbus.Error) -> i32 {
	ctx := cast(^EventContext)userdata
	context = runtime_context

	id: u32
	reason: u32

	sdbus.message_read(m, {'u', &id}, {'u', &reason})

	log.debugf("Notification closed: %v with ID %v (ctx id: %v)", reason, id, ctx.noti_id)

	if id != ctx.noti_id {
		log.warnf("The IDs %v and %v don't match, ignoring.", id, ctx.noti_id)
		return 0
	}
	return 0
}

on_action_invoked :: proc "c" (m: sdbus.Message, userdata: rawptr, err: sdbus.Error) -> i32 {
	context = runtime_context
	ctx := cast(^EventContext)userdata

	config_str, gcerr := get_config_file(context.temp_allocator)
	assert(gcerr == nil, "config file not found")
	config, pcerr := parse_config_file(config_str)
	assert(pcerr == nil, "config file couldn't be parsed")
	defer free_config(&config)

	id: u32
	action: cstring

	sdbus.message_read(m, {'u', &id}, {'s', &action})

	log.debugf("Clicked: %v with ID %v (ctx id: %v)", action, id, ctx.noti_id)

	if id != ctx.noti_id {
		log.warnf("The IDs %v and %v don't match, ignoring.", id, ctx.noti_id)
		return 0
	}

	if action == "update" {
		pprint_info("Updating...")

		exe_path, geperr := os.get_executable_path(context.temp_allocator)
		if geperr != nil {
			pprint_error(geperr, "couldn't get executable path")
			return 0
		}

		cmd := join_prefix(config.terminal_prefix[:], {exe_path, "update", "-nosync"})
		defer delete(cmd)

		oterr := open_terminal(cmd[:], wait = false)

		if oterr != nil {
			pprint_error(oterr, "error trying to open the terminal")
		} else {
			pprint_info("Running update command complete.")
		}
	} else if action == "cancel" {
		fmt.println("Canceled update.")
		when D_EXIT_EVENT_ON_CANCEL {
			sdevent.exit(ctx.event, 0)
		}
	}
	return 0
}

__get_last_notif :: proc(db: ^sqlite.Connection) -> u64 {
	last_notification, err := get_setting(db, "last_notification", u64)
	if err != nil {
		pprint_warning("Couldn't get the last notification time, assuming none exists")
		now := cast(u64)time.time_to_unix(time.now())
		if err := set_setting(db, "last_notification", twrite_uint(now, 10)); err != nil {
			pprint_error(err, "error while writing to config")
			os.exit(1)
		}
		return now
	}
	return last_notification
}

on_interval :: proc "system" (event_source: sdevent.Event_Source, usec: u64, data: rawptr) -> i32 {
	context = runtime_context
	ctx := cast(^EventContext)data
	should_reschedule := true

	config_str, gcerr := get_config_file(context.temp_allocator)
	assert(gcerr == nil, "config file not found")
	config, pcerr := parse_config_file(config_str)
	assert(pcerr == nil, "config file couldn't be parsed")
	defer free_config(&config)

	event_now: u64
	sdevent.now(ctx.event, posix.CLOCK_MONOTONIC, &event_now)

	defer if should_reschedule {
		log.info("scheduling timer to", config.interval * 60, "seconds later...")
		when D_FAST_RESCHEDULE {
			sdevent.source_set_time(event_source, event_now + sec_to_micro(u64(D_FAST_RTIME)))
		} else {
			sdevent.source_set_time(
				event_source,
				event_now + sec_to_micro(u64(config.interval * 60)),
			)
		}
		sdevent.source_set_enabled(event_source, .ONESHOT)
		log.info("scheduled timer")
		now := cast(u64)time.time_to_unix(time.now())
		if err := set_setting(ctx.db, "last_notification", twrite_uint(now, 10)); err != nil {
			pprint_error(err, "error while writing to config")
			os.exit(1)
		}
	}

	last_notification := __get_last_notif(ctx.db)

	unix_now := time.time_to_unix(time.now())
	rem_time := (unix_now - i64(last_notification)) / 60

	when !D_FAST_RESCHEDULE {
		if !(ctx.intervals_reached == 0 && config.check_on_startup) && rem_time < config.interval {
			pprint_warning(
				"It has only been %v minutes since the last interval, so I'll be rescheduling it to check after %v minutes.",
				rem_time,
				config.interval - rem_time,
			)
			secs := sec_to_micro(cast(u64)(config.interval - rem_time) * 60)
			sdevent.source_set_time(event_source, event_now + secs)
			sdevent.source_set_enabled(event_source, .ONESHOT)
			should_reschedule = false
			return 0
		}
	}

	if config.check_on_startup && ctx.intervals_reached == 0 {
		pprint_info("Checking once on startup (as per your configuration)...")
	} else {
		pprint_info("Interval reached (%v mins). Checking updates...", config.interval)
	}

	packages, perr := get_updates(sync = false when D_DISABLE_SYNC else true)
	defer free_packages(packages)
	if perr != nil {
		pprint_error(perr, "Error while fetching updates")
		should_reschedule = true
		return 0
	}

	size: i64 = 0
	for pkg in packages do size += pkg.dl_size

	when !D_FAST_RESCHEDULE {
		if len(packages) <= 0 {
			pprint_info("No updates found. Recheduling...")
			should_reschedule = true
			return 0
		}

		if size < config.minimum_n_size {
			pprint_warning(
				"The total upgrade size is %v bytes, but minimum is set to %v bytes. Ignoring.",
				size,
				config.minimum_n_size,
			)
			should_reschedule = true
			return 0
		}

		if i64(len(packages)) < config.minimum_n_packages {
			pprint_warning(
				"Only %v packages have updates, but minimum is set to %v. Ignoring.",
				len(packages),
				config.minimum_n_packages,
			)
			should_reschedule = true
			return 0
		}
	}

	urgency := byte(D_URGENCY)
	transient := i32(true)

	hints: Hints_Type
	hints["urgency"] = {
		code = 'y',
		val  = &urgency,
	}
	hints["transient"] = {
		code = 'b',
		val  = &transient,
	}
	defer delete(hints)

	noti_id, nerr := send_notification(
		ctx.bus,
		0,
		"Archup",
		"software-update-available",
		"System upgrade available!",
		fmt.tprintf(
			"%v packages can be upgraded (%v MB). Do you wish to upgrade your system?",
			len(packages),
			size / 1024 / 1024,
		),
		{"update", "Upgrade", "cancel", "Cancel"},
		hints,
		0,
	)
	ctx.noti_id = noti_id

	ctx.intervals_reached += 1

	if nerr != nil {
		pprint_error(nerr, "Couldn't dispatch notification")
	}

	return 0
}

// This exists because inotify is too fast and spammny.
on_debounce_timer :: proc "system" (
	event_source: sdevent.Event_Source,
	usec: u64,
	data: rawptr,
) -> i32 {
	context = runtime_context
	ctx := cast(^EventContext)data

	config_checker_last = time.now()

	config_str, gcerr := get_config_file(context.temp_allocator)
	if gcerr != nil {
		pprint_error(gcerr, "couldn't find config file")
	}
	config, pcerr := parse_config_file(config_str)
	defer free_config(&config)

	if pcerr != nil {
		pprint_error(pcerr, "Couldn't parse the Lua config file")
		return 0
	}

	log.debug("new config =", config)
	pprint_info("New configuration has been parsed and loaded successfully.")

	event_now: u64
	sdevent.now(ctx.event, posix.CLOCK_MONOTONIC, &event_now)

	last_notification := __get_last_notif(ctx.db)

	unix_now := time.time_to_unix(time.now())
	rem_time := (unix_now - i64(last_notification)) / 60

	if rem_time < config.interval {
		pprint_warning("Scheduling next interval after %v minutes.", config.interval - rem_time)
	}

	secs := sec_to_micro(cast(u64)(config.interval - rem_time) * 60)
	sdevent.source_set_time(ctx.time_evt_source, event_now + secs)
	sdevent.source_set_enabled(ctx.time_evt_source, .ONESHOT)

	return 0
}

on_config_change :: proc "system" (
	event_source: sdevent.Event_Source,
	inotify_event: rawptr,
	data: rawptr,
) -> i32 {
	context = runtime_context
	ctx := cast(^EventContext)data
	inotify_event := cast(^linux.Inotify_Event)inotify_event

	if inotify_event.len < 0 {
		return 0
	}

	offset := size_of(linux.Inotify_Event)
	base_ptr := cast([^]u8)inotify_event
	name_ptr := base_ptr[offset:offset + int(inotify_event.len)]
	filename := strings.trim_right_null(string(name_ptr))

	if filename != "config.lua" {
		log.debug("ignoring because filename =", filename, "(not config.lua)")
		return 0
	}

	now: u64
	sdevent.now(ctx.event, posix.CLOCK_MONOTONIC, &now)

	// Now only the last event would be considered when inotify spams events
	sdevent.source_set_time(ctx.debounce_evt_source, now + 500_000) // 500ms
	sdevent.source_set_enabled(ctx.debounce_evt_source, .ONESHOT)
	return 0
}

event_loop :: proc(db: ^sqlite.Connection, config: ^Config, config_path: string) {
	bus: sdbus.Bus = nil
	sdbus.open_user(&bus)
	defer sdbus.flush_close_unref(bus)

	event: sdevent.Event = nil
	sdevent.default(&event)
	defer sdevent.unref(event)

	sdbus.attach_event(bus, event, .NORMAL)
	defer sdbus.detach_event(bus)

	inotify_source: sdevent.Event_Source = nil
	time_source: sdevent.Event_Source = nil

	runtime_context = context
	ctx := EventContext {
		db          = db,
		config_path = config_path,
		bus         = bus,
		event       = event,
	}

	defer {
		sdevent.source_unref(ctx.time_evt_source)
		sdevent.source_unref(ctx.debounce_evt_source)
		sdevent.source_unref(inotify_source)
	}

	signals := enable_notifications(bus, on_action_invoked, on_action_closed, &ctx)
	defer disable_notifications(signals)

	config_dir := strings.clone_to_cstring(filepath.dir(config_path), context.temp_allocator)

	event_now: u64
	sdevent.now(event, posix.CLOCK_MONOTONIC, &event_now)

	sdevent.add_time(
		event,
		&ctx.time_evt_source,
		posix.CLOCK_MONOTONIC,
		event_now,
		100,
		on_interval,
		&ctx,
	)

	kv_print("Interval", fmt.tprint(config.interval, "minutes"))
	kv_print("Minimum Size Required", fmt.tprint(config.minimum_n_size, "bytes"))
	kv_print("Minimum Packages Required", fmt.tprint(config.minimum_n_packages, "packages"))

	sdevent.add_time(
		event,
		&ctx.debounce_evt_source,
		posix.CLOCK_MONOTONIC,
		max(u64),
		0,
		on_debounce_timer,
		&ctx,
	)
	sdevent.source_set_enabled(ctx.debounce_evt_source, .OFF)

	r := sdevent.add_inotify(
		event,
		&inotify_source,
		config_dir, // doesn't always work if config_path is provided
		{.CREATE, .MODIFY, .MOVED_TO, .CLOSE_WRITE},
		on_config_change,
		&ctx,
	)
	kv_print("Watching For Changes", config_path)

	sdevent.loop(event)
}
