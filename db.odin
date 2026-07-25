package main

import "./ext/sqlite/"
import sa "./ext/sqlite/addons/"
import "core:fmt"
import "core:path/filepath"
import "core:strconv"
import "core:strings"

MIGRATIONS: []string : {
	`CREATE TABLE SystemSettings (
		key TEXT NOT NULL,
		value TEXT NOT NULL,
		CONSTRAINT PK_SystemSettings_key
		    PRIMARY KEY(key)
	)`,
}

get_db_path :: proc(allocator := context.allocator) -> (path: string, err: Error) {
	context.allocator = allocator
	conf_path := get_config_path() or_return
	joined := filepath.join({conf_path, "../db.sqlite3"}) or_return
	path = joined
	return
}

open_db :: proc(db: ^^sqlite.Connection) -> (err: Error) {
	db_path := get_db_path(context.temp_allocator) or_return
	if rc := sqlite.open(strings.unsafe_string_to_cstring(db_path), db); rc != .Ok {
		return AppError {
			.Database_Error,
			fmt.tprintf("Couldn't open the databasee at %v, result code: %v", db_path, rc),
		}
	}
	return
}

set_setting :: proc(
	db: ^sqlite.Connection,
	key: string,
	value: sa.Query_Param_Value,
) -> (
	err: Error,
) {
	rc := sa.execute(
		db,
		`INSERT INTO SystemSettings(key, value) VALUES (?1, ?2)
			                      ON CONFLICT(key) DO UPDATE SET value = ?2;`,
		{{1, key}, {2, value}},
	)
	if rc != .Ok {
		msg := fmt.tprintf("Couldn't set setting %v: %v (%v)", key, string(sqlite.errmsg(db)), rc)
		return AppError{.Database_Error, msg}
	}

	return
}

get_setting :: proc(
	db: ^sqlite.Connection,
	key: string,
	$type: typeid,
) -> (
	value: type,
	err: Error,
) {
	settings: [dynamic]struct {
		key:   string `sqlite:"key"`,
		value: string `sqlite:"value"`,
	}
	defer {
		for s in settings {
			delete(s.key)
			delete(s.value)
		}
		delete(settings)
	}

	rc := sa.query(
		db,
		&settings,
		"SELECT key, value FROM SystemSettings WHERE key = ?",
		{{1, key}},
	)

	if rc != .Ok {
		msg := fmt.tprintf("Couldn't get setting %v: %v (%v)", key, string(sqlite.errmsg(db)), rc)
		return value, AppError{.Database_Error, msg}
	}

	if len(settings) == 0 {
		msg := "No matches were found"
		return value, AppError{.Database_Error, msg}
	}

	when type == string {
		value = strings.clone_from_string(settings[0].value)
	} else when type == u64 {
		val, ok := strconv.parse_u64(settings[0].value)
		if !ok {
			msg := fmt.tprintf("Couldn't parse %w for key %w as u64", settings[0].value, key)
			return value, AppError{.Database_Error, msg}
		}
		value = val
	} else {
		fmt.panicf("Conversion not yet supported: %v", typeid_of(type))
	}

	return
}

migrate :: proc(db: ^sqlite.Connection) -> (err: Error) {
	sa.config.extra_runtime_checks = true

	version: i32
	{
		stmt: ^sqlite.Statement
		defer sqlite.finalize(stmt)
		rc := sa.prepare(db, &stmt, "PRAGMA user_version;")
		assert(rc == .Ok)
		rc = sqlite.step(stmt)
		assert(rc == .Row)
		version = sqlite.column_int(stmt, 0)
	}

	kv_print("Current Migration", version)

	migrations := MIGRATIONS

	assert(sa.execute(db, "BEGIN;") == .Ok)
	for migration, index in migrations[version:] {
		cur := version + i32(index) + 1
		if rc := sa.execute(db, migration); rc != .Ok {
			msg := string(sqlite.errmsg(db))
			assert(sa.execute(db, "ROLLBACK;") == .Ok)
			return AppError {
				.Database_Error,
				fmt.tprintf("Error while executing the migration %v: %v", cur, msg),
			}
		}
		if rc := sa.execute(db, fmt.tprintf("PRAGMA user_version = %v", cur)); rc != .Ok {
			assert(sa.execute(db, "ROLLBACK;") == .Ok)
			return AppError{.Database_Error, fmt.tprintf("Couldn't set user_version to %v", index)}
		}
		kv_print(
			"Completed Migration",
			fmt.tprintf("%v (%v left)", cur, len(migrations[version:]) - index - 1),
		)
	}
	assert(sa.execute(db, "COMMIT;") == .Ok)

	return
}
