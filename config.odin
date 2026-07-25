package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import lua "vendor:lua/5.4"

APP_NAME :: "archup"
CONFIG_FILE_NAME :: "config.lua"

Config :: struct {
	interval:              i64,
	terminal_prefix:       [dynamic]string,
	pacman_config_content: string,
	check_on_startup:      bool,
	minimum_n_packages:    i64,
}

free_config :: proc(config: ^Config) {
	for pref in config.terminal_prefix {
		delete(pref)
	}
	delete(config.terminal_prefix)
	delete(config.pacman_config_content)
}

get_config_path :: proc(allocator := context.allocator) -> (path: string, err: Error) {
	context.allocator = allocator
	config_dir := os.user_config_dir(allocator) or_return
	joined := filepath.join({config_dir, APP_NAME, CONFIG_FILE_NAME}) or_return
	return joined, err
}

get_config_file :: proc(allocator := context.allocator) -> (content: string, err: Error) {
	context.allocator = allocator
	path := get_config_path() or_return
	data := os.read_entire_file(path, context.allocator) or_return
	return string(data), err
}

parse_config_file :: proc(
	content: string,
	allocator := context.allocator,
) -> (
	config: Config,
	err: Error,
) {
	context.allocator = allocator

	state := lua.L_newstate()
	lua.L_openlibs(state)

	status := lua.L_dostring(state, strings.unsafe_string_to_cstring(content))
	if status != i32(lua.Status.OK) {
		return config, LuaError{status = status, msg = string(lua.tostring(state, -1))}
	}

	if !lua.istable(state, -1) {
		return config, AppError {
			.Invalid_Config_File,
			"File must return a table containing the configuration.",
		}
	}

	interval := get_field(state, "interval", i64) or_return
	config.interval = interval

	terminal_prefix := get_field(state, "terminal_prefix", [dynamic]string) or_return
	config.terminal_prefix = terminal_prefix

	pacman_config_content := get_field(state, "pacman_config_content", string) or_return
	config.pacman_config_content = pacman_config_content

	check_on_startup := get_field(state, "check_on_startup", bool) or_return
	config.check_on_startup = check_on_startup

	minimum_n_packages := get_field(state, "minimum_n_packages", i64) or_return
	config.minimum_n_packages = minimum_n_packages

	lua.close(state)
	return config, nil
}

lua_type_to_typeid :: proc(type: lua.Type) -> typeid {
	#partial switch type {
	case .NIL:
		return nil
	case .STRING:
		return string
	case .NUMBER:
		return i64
	case .BOOLEAN:
		return bool
	}
	panic("unreachable")
}

@(private)
get_field :: proc(
	state: ^lua.State,
	name: string,
	$value_type: typeid,
	required: bool = true,
	allocator := context.allocator,
) -> (
	value: value_type,
	err: Error,
) {
	context.allocator = allocator

	type := lua.getfield(state, -1, strings.unsafe_string_to_cstring(name))
	typed_type := lua.Type(type)

	if typed_type == .NIL {
		return value,
			required ? AppError{.Required_Field_Missing, fmt.tprint("Field doesn't exist but is required (value is nil):", name)} : nil
	}

	if typed_type != .TABLE {
		parsed_type := lua_type_to_typeid(lua.Type(type))
		if parsed_type != typeid_of(value_type) {
			return value, AppError {
				.Required_Field_Invalid,
				fmt.tprintf(
					"Field '%v' evaluated as `%v` but it should be `%v`.",
					name,
					parsed_type,
					typeid_of(value_type),
				),
			}
		}
	}

	when value_type == string {
		value = strings.clone_from_cstring(lua.tostring(state, -1))
	} else when value_type == i64 {
		value = i64(lua.tointeger(state, -1))
	} else when value_type == bool {
		value = bool(lua.toboolean(state, -1))
	} else when value_type == [dynamic]string {
		value = make([dynamic]string)
		arr_len := uint(lua.rawlen(state, -1))
		for i: uint = 1; i <= arr_len; i += 1 {
			lua.rawgeti(state, -1, lua.Integer(i))
			arr_val := lua.tostring(state, -1)
			append(&value, strings.clone_from_cstring(arr_val))
			lua.pop(state, 1)
		}
	} else {
		panic(fmt.tprintf("There is no support for `%v` type yet.", typeid_of(value_type)))
	}

	lua.pop(state, 1)
	return
}
