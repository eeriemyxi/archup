/*
 * alpm.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *  Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
 *  Copyright (c) 2005 by Christian Hamar <krics@linuxforum.hu>
 *  Copyright (c) 2005, 2006 by Miklos Vajna <vmiklos@frugalware.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/** @mainpage alpm
 *
 * libalpm is a package management library, primarily used by pacman.
 */
package alpm_auto

import "core:sys/posix"
import "core:c"

foreign import lib "system:alpm"
_ :: lib

import "core:c/libc"
import "core:sys/linux"


/** The libalpm context handle.
*
* This struct represents an instance of libalpm.
* @ingroup libalpm_handle
*/
Handle :: _Alpm_Handle

/** A database.
*
* A database is a container that stores metadata about packages.
*
* A database can be located on the local filesystem or on a remote server.
*
* To use a database, it must first be registered via \link alpm_register_syncdb \endlink.
* If the database is already present in dbpath then it will be usable. Otherwise,
* the database needs to be downloaded using \link alpm_db_update \endlink. Even if the
* source of the database is the local filesystem.
*
* After this, the database can be used to query packages and groups. Any packages or groups
* from the database will continue to be owned by the database and do not need to be freed by
* the user. They will be freed when the database is unregistered.
*
* Databases are automatically unregistered when the \link alpm_handle_t \endlink is released.
* @ingroup libalpm_databases
*/
Db :: _Alpm_Db

/** A package.
*
* A package can be loaded from disk via \link alpm_pkg_load \endlink or retrieved from a database.
* Packages from databases are automatically freed when the database is unregistered. Packages loaded
* from a file must be freed manually.
*
* Packages can then be queried for metadata or added to a transaction
* to be added or removed from the system.
* @ingroup libalpm_packages
*/
Pkg :: _Alpm_Pkg

/** The extended data type used to store non-standard package data fields
* @ingroup libalpm_packages
*/
_Alpm_Pkg_Xdata :: struct {
	name:  cstring,
	value: cstring,
}

/** The extended data type used to store non-standard package data fields
* @ingroup libalpm_packages
*/
Pkg_Xdata :: _Alpm_Pkg_Xdata

/** The time type used by libalpm. Represents a unix time stamp
* @ingroup libalpm_misc */
Time :: i64

/** File in a package */
_Alpm_File :: struct {
	/** Name of the file */
	name: cstring,

	/** Size of the file */
	size: posix.off_t,

	/** The file's permissions */
	mode: u32,
}

/** File in a package */
File :: _Alpm_File

/** Package filelist container */
_Alpm_Filelist :: struct {
	/** Amount of files in the array */
	count: i32,

	/** An array of files */
	files: ^libc.FILE,
}

/** Package filelist container */
Filelist :: _Alpm_Filelist

/** Local package or package file backup entry */
_Alpm_Backup :: struct {
	/** Name of the file (without .pacsave extension) */
	name: cstring,

	/** Hash of the filename (used internally) */
	hash: cstring,
}

/** Local package or package file backup entry */
Backup :: _Alpm_Backup

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Determines whether a package filelist contains a given path.
	* The provided path should be relative to the install root with no leading
	* slashes, e.g. "etc/localtime". When searching for directories, the path must
	* have a trailing slash.
	* @param filelist a pointer to a package filelist
	* @param path the path to search for in the package
	* @return a pointer to the matching file or NULL if not found
	*/
	filelist_contains :: proc(filelist: ^Filelist, path: cstring) -> ^libc.FILE ---
}

/** Package group */
_Alpm_Group :: struct {
	/** group name */
	name: cstring,

	/** list of alpm_pkg_t packages */
	packages: ^List,
}

/** Package group */
Group :: _Alpm_Group

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Find group members across a list of databases.
	* If a member exists in several databases, only the first database is used.
	* IgnorePkg is also handled.
	* @param dbs the list of alpm_db_t *
	* @param name the name of the group
	* @return the list of alpm_pkg_t * (caller is responsible for alpm_list_free)
	*/
	find_group_pkgs :: proc(dbs: ^List, name: cstring) -> ^List ---
}

/** libalpm's error type */
_Alpm_Errno :: enum u32 {
	/** No error */
	OK                            = 0,

	/** Failed to allocate memory */
	MEMORY                        = 1,

	/** A system error occurred */
	SYSTEM                        = 2,

	/** Permmision denied */
	BADPERMS                      = 3,

	/** Should be a file */
	NOT_A_FILE                    = 4,

	/** Should be a directory */
	NOT_A_DIR                     = 5,

	/** Function was called with invalid arguments */
	WRONG_ARGS                    = 6,

	/** Insufficient disk space */
	DISK_SPACE                    = 7,

	/* Interface */
	/** Handle should be null */
	HANDLE_NULL                   = 8,

	/** Handle should not be null */
	HANDLE_NOT_NULL               = 9,

	/** Failed to acquire lock */
	HANDLE_LOCK                   = 10,

	/* Databases */
	/** Failed to open database */
	DB_OPEN                       = 11,

	/** Failed to create database */
	DB_CREATE                     = 12,

	/** Database should not be null */
	DB_NULL                       = 13,

	/** Database should be null */
	DB_NOT_NULL                   = 14,

	/** The database could not be found */
	DB_NOT_FOUND                  = 15,

	/** Database is invalid */
	DB_INVALID                    = 16,

	/** Database has an invalid signature */
	DB_INVALID_SIG                = 17,

	/** The localdb is in a newer/older format than libalpm expects */
	DB_VERSION                    = 18,

	/** Failed to write to the database */
	DB_WRITE                      = 19,

	/** Failed to remove entry from database */
	DB_REMOVE                     = 20,

	/* Servers */
	/** Server URL is in an invalid format */
	SERVER_BAD_URL                = 21,

	/** The database has no configured servers */
	SERVER_NONE                   = 22,

	/* Transactions */
	/** A transaction is already initialized */
	TRANS_NOT_NULL                = 23,

	/** A transaction has not been initialized */
	TRANS_NULL                    = 24,

	/** Duplicate target in transaction */
	TRANS_DUP_TARGET              = 25,

	/** Duplicate filename in transaction */
	TRANS_DUP_FILENAME            = 26,

	/** A transaction has not been initialized */
	TRANS_NOT_INITIALIZED         = 27,

	/** Transaction has not been prepared */
	TRANS_NOT_PREPARED            = 28,

	/** Transaction was aborted */
	TRANS_ABORT                   = 29,

	/** Failed to interrupt transaction */
	TRANS_TYPE                    = 30,

	/** Tried to commit transaction without locking the database */
	TRANS_NOT_LOCKED              = 31,

	/** A hook failed to run */
	TRANS_HOOK_FAILED             = 32,

	/* Packages */
	/** Package not found */
	PKG_NOT_FOUND                 = 33,

	/** Package is in ignorepkg */
	PKG_IGNORED                   = 34,

	/** Package is invalid */
	PKG_INVALID                   = 35,

	/** Package has an invalid checksum */
	PKG_INVALID_CHECKSUM          = 36,

	/** Package has an invalid signature */
	PKG_INVALID_SIG               = 37,

	/** Package does not have a signature */
	PKG_MISSING_SIG               = 38,

	/** Cannot open the package file */
	PKG_OPEN                      = 39,

	/** Failed to remove package files */
	PKG_CANT_REMOVE               = 40,

	/** Package has an invalid name */
	PKG_INVALID_NAME              = 41,

	/** Package has an invalid architecture */
	PKG_INVALID_ARCH              = 42,

	/* Signatures */
	/** Signatures are missing */
	SIG_MISSING                   = 43,

	/** Signatures are invalid */
	SIG_INVALID                   = 44,

	/* Dependencies */
	/** Dependencies could not be satisfied */
	UNSATISFIED_DEPS              = 45,

	/** Conflicting dependencies */
	CONFLICTING_DEPS              = 46,

	/** Files conflict */
	FILE_CONFLICTS                = 47,

	/* Misc */
	/** Download failed */
	RETRIEVE                      = 48,

	/** Invalid Regex */
	INVALID_REGEX                 = 49,

	/* External library errors */
	/** Error in libarchive */
	LIBARCHIVE                    = 50,

	/** Error in libcurl */
	LIBCURL                       = 51,

	/** Error in external download program */
	EXTERNAL_DOWNLOAD             = 52,

	/** Error in gpgme */
	GPGME                         = 53,

	/** Missing compile-time features */
	MISSING_CAPABILITY_SIGNATURES = 54,
}

/** libalpm's error type */
Errno :: _Alpm_Errno

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Returns the current error code from the handle.
	* @param handle the context handle
	* @return the current error code of the handle
	*/
	errno :: proc(handle: ^Handle) -> Errno ---

	/** Returns the string corresponding to an error number.
	* @param err the error code to get the string for
	* @return the string relating to the given error code
	*/
	strerror :: proc(err: Errno) -> cstring ---

	/** Initializes the library.
	* Creates handle, connects to database and creates lockfile.
	* This must be called before any other functions are called.
	* @param root the root path for all filesystem operations
	* @param dbpath the absolute path to the libalpm database
	* @param err an optional variable to hold any error return codes
	* @return a context handle on success, NULL on error, err will be set if provided
	*/
	initialize :: proc(root: cstring, dbpath: cstring, err: ^Errno) -> ^Handle ---

	/** Release the library.
	* Disconnects from the database, removes handle and lockfile
	* This should be the last alpm call you make.
	* After this returns, handle should be considered invalid and cannot be reused
	* in any way.
	* @param handle the context handle
	* @return 0 on success, -1 on error
	*/
	release :: proc(handle: ^Handle) -> i32 ---
}

/** PGP signature verification options */
_Alpm_Siglevel :: enum u32 {
	/** Packages require a signature */
	PACKAGE              = 1,

	/** Packages do not require a signature,
	* but check packages that do have signatures */
	PACKAGE_OPTIONAL     = 2,

	/* Allow packages with signatures that are marginal trust */
	PACKAGE_MARGINAL_OK  = 4,

	/** Allow packages with signatures that are unknown trust */
	PACKAGE_UNKNOWN_OK   = 8,

	/** Databases require a signature */
	DATABASE             = 1024,

	/** Databases do not require a signature,
	* but check databases that do have signatures */
	DATABASE_OPTIONAL    = 2048,

	/** Allow databases with signatures that are marginal trust */
	DATABASE_MARGINAL_OK = 4096,

	/** Allow databases with signatures that are unknown trust */
	DATABASE_UNKNOWN_OK  = 8192,

	/** The Default siglevel */
	USE_DEFAULT          = 1073741824,
}

/** PGP signature verification options */
Siglevel :: _Alpm_Siglevel

/** PGP signature verification status return codes */
_Alpm_Sigstatus :: enum u32 {
	/** Signature is valid */
	VALID        = 0,

	/** The key has expired */
	KEY_EXPIRED  = 1,

	/** The signature has expired */
	SIG_EXPIRED  = 2,

	/** The key is not in the keyring */
	KEY_UNKNOWN  = 3,

	/** The key has been disabled */
	KEY_DISABLED = 4,

	/** The signature is invalid */
	INVALID      = 5,
}

/** PGP signature verification status return codes */
Sigstatus :: _Alpm_Sigstatus

/** The trust level of a PGP key */
_Alpm_Sigvalidity :: enum u32 {
	/** The signature is fully trusted */
	FULL     = 0,

	/** The signature is marginally trusted */
	MARGINAL = 1,

	/** The signature is never trusted */
	NEVER    = 2,

	/** The signature has unknown trust */
	UNKNOWN  = 3,
}

/** The trust level of a PGP key */
Sigvalidity :: _Alpm_Sigvalidity

/** A PGP key */
_Alpm_Pgpkey :: struct {
	/** The actual key data */
	data: rawptr,

	/** The key's fingerprint */
	fingerprint: cstring,

	/** UID of the key */
	uid: cstring,

	/** Name of the key's owner */
	name: cstring,

	/** Email of the key's owner */
	email: cstring,

	/** When the key was created */
	created: Time,

	/** When the key expires */
	expires: Time,

	/** The length of the key */
	length: u32,

	/** has the key been revoked */
	revoked: u32,

	/** A character representing the  encryption algorithm used by the public key
	*
	* ? = unknown
	* R = RSA
	* D = DSA
	* E = EDDSA
	*/
	pubkey_algo: i8,
}

/** A PGP key */
Pgpkey :: _Alpm_Pgpkey

/**
* Signature result. Contains the key, status, and validity of a given
* signature.
*/
_Alpm_Sigresult :: struct {
	/** The key of the signature */
	key: Pgpkey,

	/** The status of the signature */
	status: Sigstatus,

	/** The validity of the signature */
	validity: Sigvalidity,
}

/**
* Signature result. Contains the key, status, and validity of a given
* signature.
*/
Sigresult :: _Alpm_Sigresult

/**
* Signature list. Contains the number of signatures found and a pointer to an
* array of results. The array is of size count.
*/
_Alpm_Siglist :: struct {
	/** The amount of results in the array */
	count: i32,

	/** An array of sigresults */
	results: ^Sigresult,
}

/**
* Signature list. Contains the number of signatures found and a pointer to an
* array of results. The array is of size count.
*/
Siglist :: _Alpm_Siglist

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/**
	* Check the PGP signature for the given package file.
	* @param pkg the package to check
	* @param siglist a pointer to storage for signature results
	* @return 0 if valid, -1 if an error occurred or signature is invalid
	*/
	pkg_check_pgp_signature :: proc(pkg: ^Pkg, siglist: ^Siglist) -> i32 ---

	/**
	* Check the PGP signature for the given database.
	* @param db the database to check
	* @param siglist a pointer to storage for signature results
	* @return 0 if valid, -1 if an error occurred or signature is invalid
	*/
	db_check_pgp_signature :: proc(db: ^Db, siglist: ^Siglist) -> i32 ---

	/**
	* Clean up and free a signature result list.
	* Note that this does not free the siglist object itself in case that
	* was allocated on the stack; this is the responsibility of the caller.
	* @param siglist a pointer to storage for signature results
	* @return 0 on success, -1 on error
	*/
	siglist_cleanup :: proc(siglist: ^Siglist) -> i32 ---

	/**
	* Decode a loaded signature in base64 form.
	* @param base64_data the signature to attempt to decode
	* @param data the decoded data; must be freed by the caller
	* @param data_len the length of the returned data
	* @return 0 on success, -1 on failure to properly decode
	*/
	decode_signature :: proc(base64_data: cstring, data: ^^u8, data_len: ^i32) -> i32 ---

	/**
	* Extract the Issuer Key ID from a signature
	* @param handle the context handle
	* @param identifier the identifier of the key.
	* This may be the name of the package or the path to the package.
	* @param sig PGP signature
	* @param len length of signature
	* @param keys a pointer to storage for key IDs
	* @return 0 on success, -1 on error
	*/
	extract_keyid :: proc(handle: ^Handle, identifier: cstring, sig: ^u8, len: i32, keys: ^^List) -> i32 ---
}

/** Types of version constraints in dependency specs. */
_Alpm_Depmod :: enum u32 {
	/** No version constraint */
	ANY = 1,

	/** Test version equality (package=x.y.z) */
	EQ  = 2,

	/** Test for at least a version (package>=x.y.z) */
	GE  = 3,

	/** Test for at most a version (package<=x.y.z) */
	LE  = 4,

	/** Test for greater than some version (package>x.y.z) */
	GT  = 5,

	/** Test for less than some version (package<x.y.z) */
	LT  = 6,
}

/** Types of version constraints in dependency specs. */
Depmod :: _Alpm_Depmod

/**
* File conflict type.
* Whether the conflict results from a file existing on the filesystem, or with
* another target in the transaction.
*/
_Alpm_Fileconflicttype :: enum u32 {
	/** The conflict results with a another target in the transaction */
	TARGET     = 1,

	/** The conflict results from a file existing on the filesystem */
	FILESYSTEM = 2,
}

/**
* File conflict type.
* Whether the conflict results from a file existing on the filesystem, or with
* another target in the transaction.
*/
Fileconflicttype :: _Alpm_Fileconflicttype

/** The basic dependency type.
*
* This type is used throughout libalpm, not just for dependencies
* but also conflicts and providers. */
_Alpm_Depend :: struct {
	/**  Name of the provider to satisfy this dependency */
	name: cstring,

	/**  Version of the provider to match against (optional) */
	version: cstring,

	/** A description of why this dependency is needed (optional) */
	desc: cstring,

	/** A hash of name (used internally to speed up conflict checks) */
	name_hash: c.ulong,

	/** How the version should match against the provider */
	mod: Depmod,
}

/** The basic dependency type.
*
* This type is used throughout libalpm, not just for dependencies
* but also conflicts and providers. */
Depend :: _Alpm_Depend

/** Missing dependency. */
_Alpm_Depmissing :: struct {
	/** Name of the package that has the dependency */
	target: cstring,

	/** The dependency that was wanted */
	depend: ^Depend,

	/** If the depmissing was caused by a conflict, the name of the package
	* that would be installed, causing the satisfying package to be removed */
	causingpkg: cstring,
}

/** Missing dependency. */
Depmissing :: _Alpm_Depmissing

/** A conflict that has occurred between two packages. */
_Alpm_Conflict :: struct {
	/** The first package */
	package1: ^Pkg,

	/** The second package */
	package2: ^Pkg,

	/** The conflict */
	reason: ^Depend,
}

/** A conflict that has occurred between two packages. */
Conflict :: _Alpm_Conflict

/** File conflict.
*
* A conflict that has happened due to a two packages containing the same file,
* or a package contains a file that is already on the filesystem and not owned
* by that package. */
_Alpm_Fileconflict :: struct {
	/** The name of the package that caused the conflict */
	target: cstring,

	/** The type of conflict */
	type: Fileconflicttype,

	/** The name of the file that the package conflicts with */
	file: cstring,

	/** The name of the package that also owns the file if there is one*/
	ctarget: cstring,
}

/** File conflict.
*
* A conflict that has happened due to a two packages containing the same file,
* or a package contains a file that is already on the filesystem and not owned
* by that package. */
Fileconflict :: _Alpm_Fileconflict

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Checks dependencies and returns missing ones in a list.
	* Dependencies can include versions with depmod operators.
	* @param handle the context handle
	* @param pkglist the list of local packages
	* @param remove an alpm_list_t* of packages to be removed
	* @param upgrade an alpm_list_t* of packages to be upgraded (remove-then-upgrade)
	* @param reversedeps handles the backward dependencies
	* @return an alpm_list_t* of alpm_depmissing_t pointers.
	*/
	checkdeps :: proc(handle: ^Handle, pkglist: ^List, remove: ^List, upgrade: ^List, reversedeps: i32) -> ^List ---

	/** Find a package satisfying a specified dependency.
	* The dependency can include versions with depmod operators.
	* @param pkgs an alpm_list_t* of alpm_pkg_t where the satisfyer will be searched
	* @param depstring package or provision name, versioned or not
	* @return a alpm_pkg_t* satisfying depstring
	*/
	find_satisfier :: proc(pkgs: ^List, depstring: cstring) -> ^Pkg ---

	/** Find a package satisfying a specified dependency.
	* First look for a literal, going through each db one by one. Then look for
	* providers. The first satisfyer that belongs to an installed package is
	* returned. If no providers belong to an installed package then an
	* alpm_question_select_provider_t is created to select the provider.
	* The dependency can include versions with depmod operators.
	*
	* @param handle the context handle
	* @param dbs an alpm_list_t* of alpm_db_t where the satisfyer will be searched
	* @param depstring package or provision name, versioned or not
	* @return a alpm_pkg_t* satisfying depstring
	*/
	find_dbs_satisfier :: proc(handle: ^Handle, dbs: ^List, depstring: cstring) -> ^Pkg ---

	/** Check the package conflicts in a database
	*
	* @param handle the context handle
	* @param pkglist the list of packages to check
	*
	* @return an alpm_list_t of alpm_conflict_t
	*/
	checkconflicts :: proc(handle: ^Handle, pkglist: ^List) -> ^List ---

	/** Returns a newly allocated string representing the dependency information.
	* @param dep a dependency info structure
	* @return a formatted string, e.g. "glibc>=2.12"
	*/
	dep_compute_string :: proc(dep: ^Depend) -> cstring ---

	/** Return a newly allocated dependency information parsed from a string
	*\link alpm_dep_free should be used to free the dependency \endlink
	* @param depstring a formatted string, e.g. "glibc=2.12"
	* @return a dependency info structure
	*/
	dep_from_string :: proc(depstring: cstring) -> ^Depend ---

	/** Free a dependency info structure
	* @param dep struct to free
	*/
	dep_free :: proc(dep: ^Depend) ---

	/** Free a fileconflict and its members.
	* @param conflict the fileconflict to free
	*/
	fileconflict_free :: proc(conflict: ^Fileconflict) ---

	/** Free a depmissing and its members
	* @param miss the depmissing to free
	* */
	depmissing_free :: proc(miss: ^Depmissing) ---

	/**
	* Free a conflict and its members.
	* @param conflict the conflict to free
	*/
	conflict_free :: proc(conflict: ^Conflict) ---
}

/**
* Type of events.
*/
_Alpm_Event_Type :: enum u32 {
	/** Dependencies will be computed for a package. */
	CHECKDEPS_START         = 1,

	/** Dependencies were computed for a package. */
	CHECKDEPS_DONE          = 2,

	/** File conflicts will be computed for a package. */
	FILECONFLICTS_START     = 3,

	/** File conflicts were computed for a package. */
	FILECONFLICTS_DONE      = 4,

	/** Dependencies will be resolved for target package. */
	RESOLVEDEPS_START       = 5,

	/** Dependencies were resolved for target package. */
	RESOLVEDEPS_DONE        = 6,

	/** Inter-conflicts will be checked for target package. */
	INTERCONFLICTS_START    = 7,

	/** Inter-conflicts were checked for target package. */
	INTERCONFLICTS_DONE     = 8,

	/** Processing the package transaction is starting. */
	TRANSACTION_START       = 9,

	/** Processing the package transaction is finished. */
	TRANSACTION_DONE        = 10,

	/** Package will be installed/upgraded/downgraded/re-installed/removed; See
	* alpm_event_package_operation_t for arguments. */
	PACKAGE_OPERATION_START = 11,

	/** Package was installed/upgraded/downgraded/re-installed/removed; See
	* alpm_event_package_operation_t for arguments. */
	PACKAGE_OPERATION_DONE  = 12,

	/** Target package's integrity will be checked. */
	INTEGRITY_START         = 13,

	/** Target package's integrity was checked. */
	INTEGRITY_DONE          = 14,

	/** Target package will be loaded. */
	LOAD_START              = 15,

	/** Target package is finished loading. */
	LOAD_DONE               = 16,

	/** Scriptlet has printed information; See alpm_event_scriptlet_info_t for
	* arguments. */
	SCRIPTLET_INFO          = 17,

	/** Database files will be downloaded from a repository. */
	DB_RETRIEVE_START       = 18,

	/** Database files were downloaded from a repository. */
	DB_RETRIEVE_DONE        = 19,

	/** Not all database files were successfully downloaded from a repository. */
	DB_RETRIEVE_FAILED      = 20,

	/** Package files will be downloaded from a repository. */
	PKG_RETRIEVE_START      = 21,

	/** Package files were downloaded from a repository. */
	PKG_RETRIEVE_DONE       = 22,

	/** Not all package files were successfully downloaded from a repository. */
	PKG_RETRIEVE_FAILED     = 23,

	/** Disk space usage will be computed for a package. */
	DISKSPACE_START         = 24,

	/** Disk space usage was computed for a package. */
	DISKSPACE_DONE          = 25,

	/** An optdepend for another package is being removed; See
	* alpm_event_optdep_removal_t for arguments. */
	OPTDEP_REMOVAL          = 26,

	/** A configured repository database is missing; See
	* alpm_event_database_missing_t for arguments. */
	DATABASE_MISSING        = 27,

	/** Checking keys used to create signatures are in keyring. */
	KEYRING_START           = 28,

	/** Keyring checking is finished. */
	KEYRING_DONE            = 29,

	/** Downloading missing keys into keyring. */
	KEY_DOWNLOAD_START      = 30,

	/** Key downloading is finished. */
	KEY_DOWNLOAD_DONE       = 31,

	/** A .pacnew file was created; See alpm_event_pacnew_created_t for arguments. */
	PACNEW_CREATED          = 32,

	/** A .pacsave file was created; See alpm_event_pacsave_created_t for
	* arguments. */
	PACSAVE_CREATED         = 33,

	/** Processing hooks will be started. */
	HOOK_START              = 34,

	/** Processing hooks is finished. */
	HOOK_DONE               = 35,

	/** A hook is starting */
	HOOK_RUN_START          = 36,

	/** A hook has finished running. */
	HOOK_RUN_DONE           = 37,
}

/**
* Type of events.
*/
Event_Type :: _Alpm_Event_Type

/** An event that may represent any event. */
_Alpm_Event_Any :: struct {
	/** Type of event */
	type: Event_Type,
}

/** An event that may represent any event. */
Event_Any :: _Alpm_Event_Any

/** An enum over the kind of package operations. */
_Alpm_Package_Operation :: enum u32 {
	/** Package (to be) installed. (No oldpkg) */
	INSTALL   = 1,

	/** Package (to be) upgraded */
	UPGRADE   = 2,

	/** Package (to be) re-installed */
	REINSTALL = 3,

	/** Package (to be) downgraded */
	DOWNGRADE = 4,

	/** Package (to be) removed (No newpkg) */
	REMOVE    = 5,
}

/** An enum over the kind of package operations. */
Package_Operation :: _Alpm_Package_Operation

/** A package operation event occurred. */
_Alpm_Event_Package_Operation :: struct {
	/** Type of event */
	type: Event_Type,

	/** Type of operation */
	operation: Package_Operation,

	/** Old package */
	oldpkg: ^Pkg,

	/** New package */
	newpkg: ^Pkg,
}

/** A package operation event occurred. */
Event_Package_Operation :: _Alpm_Event_Package_Operation

/** An optional dependency was removed. */
_Alpm_Event_Optdep_Removal :: struct {
	/** Type of event */
	type: Event_Type,

	/** Package with the optdep */
	pkg: ^Pkg,

	/** Optdep being removed */
	optdep: ^Depend,
}

/** An optional dependency was removed. */
Event_Optdep_Removal :: _Alpm_Event_Optdep_Removal

/** A scriptlet was ran. */
_Alpm_Event_Scriptlet_Info :: struct {
	/** Type of event */
	type: Event_Type,

	/** Line of scriptlet output */
	line: cstring,
}

/** A scriptlet was ran. */
Event_Scriptlet_Info :: _Alpm_Event_Scriptlet_Info

/** A database is missing.
*
* The database is registered but has not been downloaded
*/
_Alpm_Event_Database_Missing :: struct {
	/** Type of event */
	type: Event_Type,

	/** Name of the database */
	dbname: cstring,
}

/** A database is missing.
*
* The database is registered but has not been downloaded
*/
Event_Database_Missing :: _Alpm_Event_Database_Missing

/** A package was downloaded. */
_Alpm_Event_Pkgdownload :: struct {
	/** Type of event */
	type: Event_Type,

	/** Name of the file */
	file: cstring,
}

/** A package was downloaded. */
Event_Pkgdownload :: _Alpm_Event_Pkgdownload

/** A pacnew file was created. */
_Alpm_Event_Pacnew_Created :: struct {
	/** Type of event */
	type: Event_Type,

	/** Whether the creation was result of a NoUpgrade or not */
	from_noupgrade: i32,

	/** Old package */
	oldpkg: ^Pkg,

	/** New Package */
	newpkg: ^Pkg,

	/** Filename of the file without the .pacnew suffix */
	file: cstring,
}

/** A pacnew file was created. */
Event_Pacnew_Created :: _Alpm_Event_Pacnew_Created

/** A pacsave file was created. */
_Alpm_Event_Pacsave_Created :: struct {
	/** Type of event */
	type: Event_Type,

	/** Old package */
	oldpkg: ^Pkg,

	/** Filename of the file without the .pacsave suffix */
	file: cstring,
}

/** A pacsave file was created. */
Event_Pacsave_Created :: _Alpm_Event_Pacsave_Created

/** Kind of hook. */
_Alpm_Hook_When :: enum u32 {
	/* Pre transaction hook */
	RE_TRANSACTION  = 1,

	/* Post transaction hook */
	OST_TRANSACTION = 2,
}

/** Kind of hook. */
Hook_When :: _Alpm_Hook_When

/** pre/post transaction hooks are to be ran. */
_Alpm_Event_Hook :: struct {
	/** Type of event*/
	type: Event_Type,

	/** Type of hook */
	_when: Hook_When,
}

/** pre/post transaction hooks are to be ran. */
Event_Hook :: _Alpm_Event_Hook

/** A pre/post transaction hook was ran. */
_Alpm_Event_Hook_Run :: struct {
	/** Type of event */
	type: Event_Type,

	/** Name of hook */
	name: cstring,

	/** Description of hook to be outputted */
	desc: cstring,

	/** position of hook being run */
	position: i32,

	/** total hooks being run */
	total: i32,
}

/** A pre/post transaction hook was ran. */
Event_Hook_Run :: _Alpm_Event_Hook_Run

/** Packages downloading about to start. */
_Alpm_Event_Pkg_Retrieve :: struct {
	/** Type of event */
	type: Event_Type,

	/** Number of packages to download */
	num: i32,

	/** Total size of packages to download */
	total_size: posix.off_t,
}

/** Packages downloading about to start. */
Event_Pkg_Retrieve :: _Alpm_Event_Pkg_Retrieve

/** Events.
* This is a union passed to the callback that allows the frontend to know
* which type of event was triggered (via type). It is then possible to
* typecast the pointer to the right structure, or use the union field, in order
* to access event-specific data. */
_Alpm_Event :: struct #raw_union {
	/** Type of event it's always safe to access this. */
	type: Event_Type,

	/** The any event type. It's always safe to access this. */
	_any: Event_Any,

	/** Package operation */
	package_operation: Event_Package_Operation,

	/** An optdept was remove */
	optdep_removal: Event_Optdep_Removal,

	/** A scriptlet was ran */
	scriptlet_info: Event_Scriptlet_Info,

	/** A database is missing */
	database_missing: Event_Database_Missing,

	/** A package was downloaded */
	pkgdownload: Event_Pkgdownload,

	/** A pacnew file was created */
	pacnew_created: Event_Pacnew_Created,

	/** A pacsave file was created */
	pacsave_created: Event_Pacsave_Created,

	/** Pre/post transaction hooks are being ran */
	hook: Event_Hook,

	/** A hook was ran */
	hook_run: Event_Hook_Run,

	/** Download packages */
	pkg_retrieve: Event_Pkg_Retrieve,
}

/** Events.
* This is a union passed to the callback that allows the frontend to know
* which type of event was triggered (via type). It is then possible to
* typecast the pointer to the right structure, or use the union field, in order
* to access event-specific data. */
Event :: _Alpm_Event

/** Event callback.
*
* Called when an event occurs
* @param ctx user-provided context
* @param event the event that occurred */
Cb_Event :: proc "c" (ctx: rawptr, event: ^Event)

/**
* Type of question.
* Unlike the events or progress enumerations, this enum has bitmask values
* so a frontend can use a bitmask map to supply preselected answers to the
* different types of questions.
*/
_Alpm_Question_Type :: enum u32 {
	/** Should target in ignorepkg be installed anyway? */
	INSTALL_IGNOREPKG = 1,

	/** Should a package be replaced? */
	REPLACE_PKG       = 2,

	/** Should a conflicting package be removed? */
	CONFLICT_PKG      = 4,

	/** Should a corrupted package be deleted? */
	CORRUPTED_PKG     = 8,

	/** Should unresolvable targets be removed from the transaction? */
	REMOVE_PKGS       = 16,

	/** Provider selection */
	SELECT_PROVIDER   = 32,

	/** Should a key be imported? */
	IMPORT_KEY        = 64,
}

/**
* Type of question.
* Unlike the events or progress enumerations, this enum has bitmask values
* so a frontend can use a bitmask map to supply preselected answers to the
* different types of questions.
*/
Question_Type :: _Alpm_Question_Type

/** A question that can represent any other question. */
_Alpm_Question_Any :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer */
	answer: i32,
}

/** A question that can represent any other question. */
Question_Any :: _Alpm_Question_Any

/** Should target in ignorepkg be installed anyway? */
_Alpm_Question_Install_Ignorepkg :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer: whether or not to install pkg anyway */
	install: i32,

	/** The ignored package that we are deciding whether to install */
	pkg: ^Pkg,
}

/** Should target in ignorepkg be installed anyway? */
Question_Install_Ignorepkg :: _Alpm_Question_Install_Ignorepkg

/** Should a package be replaced? */
_Alpm_Question_Replace :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer: whether or not to replace oldpkg with newpkg */
	replace: i32,

	/** Package to be replaced */
	oldpkg: ^Pkg,

	/** Package to replace with.*/
	newpkg: ^Pkg,

	/** DB of newpkg */
	newdb: ^Db,
}

/** Should a package be replaced? */
Question_Replace :: _Alpm_Question_Replace

/** Should a conflicting package be removed? */
_Alpm_Question_Conflict :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer: whether or not to remove conflict->package2 */
	remove: i32,

	/** Conflict info */
	conflict: ^Conflict,
}

/** Should a conflicting package be removed? */
Question_Conflict :: _Alpm_Question_Conflict

/** Should a corrupted package be deleted? */
_Alpm_Question_Corrupted :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer: whether or not to remove filepath */
	remove: i32,

	/** File to remove */
	filepath: cstring,

	/** Error code indicating the reason for package invalidity */
	reason: Errno,
}

/** Should a corrupted package be deleted? */
Question_Corrupted :: _Alpm_Question_Corrupted

/** Should unresolvable targets be removed from the transaction? */
_Alpm_Question_Remove_Pkgs :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer: whether or not to skip packages */
	skip: i32,

	/** List of alpm_pkg_t* with unresolved dependencies */
	packages: ^List,
}

/** Should unresolvable targets be removed from the transaction? */
Question_Remove_Pkgs :: _Alpm_Question_Remove_Pkgs

/** Provider selection */
_Alpm_Question_Select_Provider :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer: which provider to use (index from providers) */
	use_index: i32,

	/** List of alpm_pkg_t* as possible providers */
	providers: ^List,

	/** What providers provide for */
	depend: ^Depend,
}

/** Provider selection */
Question_Select_Provider :: _Alpm_Question_Select_Provider

/** Should a key be imported? */
_Alpm_Question_Import_Key :: struct {
	/** Type of question */
	type: Question_Type,

	/** Answer: whether or not to import key */
	_import: i32,

	/** UID of the key to import */
	uid: cstring,

	/** Fingerprint the key to import */
	fingerprint: cstring,
}

/** Should a key be imported? */
Question_Import_Key :: _Alpm_Question_Import_Key

/**
* Questions.
* This is an union passed to the callback that allows the frontend to know
* which type of question was triggered (via type). It is then possible to
* typecast the pointer to the right structure, or use the union field, in order
* to access question-specific data. */
_Alpm_Question :: struct #raw_union {
	/** The type of question. It's always safe to access this. */
	type: Question_Type,

	/** A question that can represent any question.
	* It's always safe to access this. */
	_any: Question_Any,

	/** Should target in ignorepkg be installed anyway? */
	install_ignorepkg: Question_Install_Ignorepkg,

	/** Should a package be replaced? */
	replace: Question_Replace,

	/** Should a conflicting package be removed? */
	conflict: Question_Conflict,

	/** Should a corrupted package be deleted? */
	corrupted: Question_Corrupted,

	/** Should unresolvable targets be removed from the transaction? */
	remove_pkgs: Question_Remove_Pkgs,

	/** Provider selection */
	select_provider: Question_Select_Provider,

	/** Should a key be imported? */
	import_key: Question_Import_Key,
}

/**
* Questions.
* This is an union passed to the callback that allows the frontend to know
* which type of question was triggered (via type). It is then possible to
* typecast the pointer to the right structure, or use the union field, in order
* to access question-specific data. */
Question :: _Alpm_Question

/** Question callback.
*
* This callback allows user to give input and decide what to do during certain events
* @param ctx user-provided context
* @param question the question being asked.
*/
Cb_Question :: proc "c" (ctx: rawptr, question: ^Question)

/** An enum over different kinds of progress alerts. */
_Alpm_Progress :: enum u32 {
	/** Package install */
	ADD_START       = 0,

	/** Package upgrade */
	UPGRADE_START   = 1,

	/** Package downgrade */
	DOWNGRADE_START = 2,

	/** Package reinstall */
	REINSTALL_START = 3,

	/** Package removal */
	REMOVE_START    = 4,

	/** Conflict checking */
	CONFLICTS_START = 5,

	/** Diskspace checking */
	DISKSPACE_START = 6,

	/** Package Integrity checking */
	INTEGRITY_START = 7,

	/** Loading packages from disk */
	LOAD_START      = 8,

	/** Checking signatures of packages */
	KEYRING_START   = 9,
}

/** An enum over different kinds of progress alerts. */
Progress :: _Alpm_Progress

/** Progress callback
*
* Alert the front end about the progress of certain events.
* Allows the implementation of loading bars for events that
* make take a while to complete.
* @param ctx user-provided context
* @param progress the kind of event that is progressing
* @param pkg for package operations, the name of the package being operated on
* @param percent the percent completion of the action
* @param howmany the total amount of items in the action
* @param current the current amount of items completed
*/
/** Progress callback */
Cb_Progress :: proc "c" (ctx: rawptr, progress: Progress, pkg: cstring, percent: i32, howmany: i32, current: i32)

/** File download events.
* These events are reported by ALPM via download callback.
*/
_Alpm_Download_Event_Type :: enum u32 {
	/** A download was started */
	INIT      = 0,

	/** A download made progress */
	PROGRESS  = 1,

	/** Download will be retried */
	RETRY     = 2,

	/** A download completed */
	COMPLETED = 3,
}

/** File download events.
* These events are reported by ALPM via download callback.
*/
Download_Event_Type :: _Alpm_Download_Event_Type

/** Context struct for when a download starts. */
_Alpm_Download_Event_Init :: struct {
	/** whether this file is optional and thus the errors could be ignored */
	optional: i32,
}

/** Context struct for when a download starts. */
Download_Event_Init :: _Alpm_Download_Event_Init

/** Context struct for when a download progresses. */
_Alpm_Download_Event_Progress :: struct {
	/** Amount of data downloaded */
	downloaded: posix.off_t,

	/** Total amount need to be downloaded */
	total: posix.off_t,
}

/** Context struct for when a download progresses. */
Download_Event_Progress :: _Alpm_Download_Event_Progress

/** Context struct for when a download retries. */
_Alpm_Download_Event_Retry :: struct {
	/** If the download will resume or start over */
	resume: i32,
}

/** Context struct for when a download retries. */
Download_Event_Retry :: _Alpm_Download_Event_Retry

/** Context struct for when a download completes. */
_Alpm_Download_Event_Completed :: struct {
	/** Total bytes in file */
	total: posix.off_t,

	/** download result code:
	*    0 - download completed successfully
	*    1 - the file is up-to-date
	*   -1 - error
	*/
	result: i32,
}

/** Context struct for when a download completes. */
Download_Event_Completed :: _Alpm_Download_Event_Completed

/** Type of download progress callbacks.
* @param ctx user-provided context
* @param filename the name of the file being downloaded
* @param event the event type
* @param data the event data of type alpm_download_event_*_t
*/
Cb_Download :: proc "c" (ctx: rawptr, filename: cstring, event: Download_Event_Type, data: rawptr)

/** A callback for downloading files
* @param ctx user-provided context
* @param url the URL of the file to be downloaded
* @param localpath the directory to which the file should be downloaded
* @param force whether to force an update, even if the file is the same
* @return 0 on success, 1 if the file exists and is identical, -1 on
* error.
*/
Cb_Fetch :: proc "c" (ctx: rawptr, url: cstring, localpath: cstring, force: i32) -> i32

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Get the database of locally installed packages.
	* The returned pointer points to an internal structure
	* of libalpm which should only be manipulated through
	* libalpm functions.
	* @return a reference to the local database
	*/
	get_localdb :: proc(handle: ^Handle) -> ^Db ---

	/** Get the list of sync databases.
	* Returns a list of alpm_db_t structures, one for each registered
	* sync database.
	*
	* @param handle the context handle
	* @return a reference to an internal list of alpm_db_t structures
	*/
	get_syncdbs :: proc(handle: ^Handle) -> ^List ---

	/** Register a sync database of packages.
	* Databases can not be registered when there is an active transaction.
	*
	* @param handle the context handle
	* @param treename the name of the sync repository
	* @param level what level of signature checking to perform on the
	* database; note that this must be a '.sig' file type verification
	* @return an alpm_db_t* on success (the value), NULL on error
	*/
	register_syncdb :: proc(handle: ^Handle, treename: cstring, level: i32) -> ^Db ---

	/** Unregister all package databases.
	* Databases can not be unregistered while there is an active transaction.
	*
	* @param handle the context handle
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	unregister_all_syncdbs :: proc(handle: ^Handle) -> i32 ---

	/** Unregister a package database.
	* Databases can not be unregistered when there is an active transaction.
	*
	* @param db pointer to the package database to unregister
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	db_unregister :: proc(db: ^Db) -> i32 ---

	/** Get the handle of a package database.
	* @param db pointer to the package database
	* @return the alpm handle that the package database belongs to
	*/
	db_get_handle :: proc(db: ^Db) -> ^Handle ---

	/** Get the name of a package database.
	* @param db pointer to the package database
	* @return the name of the package database, NULL on error
	*/
	db_get_name :: proc(db: ^Db) -> cstring ---

	/** Get the signature verification level for a database.
	* Will return the default verification level if this database is set up
	* with ALPM_SIG_USE_DEFAULT.
	* @param db pointer to the package database
	* @return the signature verification level
	*/
	db_get_siglevel :: proc(db: ^Db) -> i32 ---

	/** Check the validity of a database.
	* This is most useful for sync databases and verifying signature status.
	* If invalid, the handle error code will be set accordingly.
	* @param db pointer to the package database
	* @return 0 if valid, -1 if invalid (pm_errno is set accordingly)
	*/
	db_get_valid :: proc(db: ^Db) -> i32 ---

	/** Get the list of servers assigned to this db.
	* @param db pointer to the database to get the servers from
	* @return a char* list of servers
	*/
	db_get_servers :: proc(db: ^Db) -> ^List ---

	/** Sets the list of servers for the database to use.
	* @param db the database to set the servers. The list will be duped and
	* the original will still need to be freed by the caller.
	* @param servers a char* list of servers.
	*/
	db_set_servers :: proc(db: ^Db, servers: ^List) -> i32 ---

	/** Add a download server to a database.
	* @param db database pointer
	* @param url url of the server
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	db_add_server :: proc(db: ^Db, url: cstring) -> i32 ---

	/** Remove a download server from a database.
	* @param db database pointer
	* @param url url of the server
	* @return 0 on success, 1 on server not present,
	* -1 on error (pm_errno is set accordingly)
	*/
	db_remove_server :: proc(db: ^Db, url: cstring) -> i32 ---

	/** Get the list of cache servers assigned to this db.
	* @param db pointer to the database to get the servers from
	* @return a char* list of servers
	*/
	db_get_cache_servers :: proc(db: ^Db) -> ^List ---

	/** Sets the list of cache servers for the database to use.
	* @param db the database to set the servers. The list will be duped and
	* the original will still need to be freed by the caller.
	* @param servers a char* list of servers.
	*/
	db_set_cache_servers :: proc(db: ^Db, servers: ^List) -> i32 ---

	/** Add a download cache server to a database.
	* @param db database pointer
	* @param url url of the server
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	db_add_cache_server :: proc(db: ^Db, url: cstring) -> i32 ---

	/** Remove a download cache server from a database.
	* @param db database pointer
	* @param url url of the server
	* @return 0 on success, 1 on server not present,
	* -1 on error (pm_errno is set accordingly)
	*/
	db_remove_cache_server :: proc(db: ^Db, url: cstring) -> i32 ---

	/** Update package databases.
	*
	* An update of the package databases in the list \a dbs will be attempted.
	* Unless \a force is true, the update will only be performed if the remote
	* databases were modified since the last update.
	*
	* This operation requires a database lock, and will return an applicable error
	* if the lock could not be obtained.
	*
	* Example:
	* @code
	* alpm_list_t *dbs = alpm_get_syncdbs(config->handle);
	* ret = alpm_db_update(config->handle, dbs, force);
	* if(ret < 0) {
	*     pm_printf(ALPM_LOG_ERROR, _("failed to synchronize all databases (%s)\n"),
	*         alpm_strerror(alpm_errno(config->handle)));
	* }
	* @endcode
	*
	* @note After a successful update, the \link alpm_db_get_pkgcache()
	* package cache \endlink will be invalidated
	* @param handle the context handle
	* @param dbs list of package databases to update
	* @param force if true, then forces the update, otherwise update only in case
	* the databases aren't up to date
	* @return 0 on success, -1 on error (pm_errno is set accordingly),
	* 1 if all databases are up to to date
	*/
	db_update :: proc(handle: ^Handle, dbs: ^List, force: i32) -> i32 ---

	/** Get a package entry from a package database.
	* Looking up a package is O(1) and will be significantly faster than
	* iterating over the pkgcahe.
	* @param db pointer to the package database to get the package from
	* @param name of the package
	* @return the package entry on success, NULL on error
	*/
	db_get_pkg :: proc(db: ^Db, name: cstring) -> ^Pkg ---

	/** Get the package cache of a package database.
	* This is a list of all packages the db contains.
	* @param db pointer to the package database to get the package from
	* @return the list of packages on success, NULL on error
	*/
	db_get_pkgcache :: proc(db: ^Db) -> ^List ---

	/** Get a group entry from a package database.
	* Looking up a group is O(1) and will be significantly faster than
	* iterating over the groupcahe.
	* @param db pointer to the package database to get the group from
	* @param name of the group
	* @return the groups entry on success, NULL on error
	*/
	db_get_group :: proc(db: ^Db, name: cstring) -> ^Group ---

	/** Get the group cache of a package database.
	* @param db pointer to the package database to get the group from
	* @return the list of groups on success, NULL on error
	*/
	db_get_groupcache :: proc(db: ^Db) -> ^List ---

	/** Searches a database with regular expressions.
	* @param db pointer to the package database to search in
	* @param needles a list of regular expressions to search for
	* @param ret pointer to list for storing packages matching all
	* regular expressions - must point to an empty (NULL) alpm_list_t *.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	db_search :: proc(db: ^Db, needles: ^List, ret: ^^List) -> i32 ---
}

/** The usage level of a database. */
_Alpm_Db_Usage :: enum u32 {
	/** Enable refreshes for this database */
	SYNC    = 1,

	/** Enable search for this database */
	SEARCH  = 2,

	/** Enable installing packages from this database */
	INSTALL = 4,

	/** Enable sysupgrades with this database */
	UPGRADE = 8,

	/** Enable all usage levels */
	ALL     = 15,
}

/** The usage level of a database. */
Db_Usage :: _Alpm_Db_Usage

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Sets the usage of a database.
	* @param db pointer to the package database to set the status for
	* @param usage a bitmask of alpm_db_usage_t values
	* @return 0 on success, or -1 on error
	*/
	db_set_usage :: proc(db: ^Db, usage: i32) -> i32 ---

	/** Gets the usage of a database.
	* @param db pointer to the package database to get the status of
	* @param usage pointer to an alpm_db_usage_t to store db's status
	* @return 0 on success, or -1 on error
	*/
	db_get_usage :: proc(db: ^Db, usage: ^i32) -> i32 ---
}

/** Logging Levels */
_Alpm_Loglevel :: enum u32 {
	/** Error */
	ERROR    = 1,

	/** Warning */
	WARNING  = 2,

	/** Debug */
	DEBUG    = 4,

	/** Function */
	FUNCTION = 8,
}

/** Logging Levels */
Loglevel :: _Alpm_Loglevel

/** The callback type for logging.
*
* libalpm will call this function whenever something is to be logged.
* many libalpm will produce log output. Additionally any calls to \link alpm_logaction
* \endlink will also call this callback.
* @param ctx user-provided context
* @param level the currently set loglevel
* @param fmt the printf like format string
* @param args printf like arguments
*/
Cb_Log :: proc "c" (ctx: rawptr, level: Loglevel, fmt: cstring, args: c.va_list)

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** A printf-like function for logging.
	* @param handle the context handle
	* @param prefix caller-specific prefix for the log
	* @param fmt output format
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	logaction :: proc(handle: ^Handle, prefix: cstring, fmt: cstring, #c_vararg _: ..any) -> i32 ---

	/** Returns the callback used for logging.
	* @param handle the context handle
	* @return the currently set log callback
	*/
	option_get_logcb :: proc(handle: ^Handle) -> Cb_Log ---

	/** Returns the callback used for logging.
	* @param handle the context handle
	* @return the currently set log callback context
	*/
	option_get_logcb_ctx :: proc(handle: ^Handle) -> rawptr ---

	/** Sets the callback used for logging.
	* @param handle the context handle
	* @param cb the cb to use
	* @param ctx user-provided context to pass to cb
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_logcb :: proc(handle: ^Handle, cb: Cb_Log, ctx: rawptr) -> i32 ---

	/** Returns the callback used to report download progress.
	* @param handle the context handle
	* @return the currently set download callback
	*/
	option_get_dlcb :: proc(handle: ^Handle) -> Cb_Download ---

	/** Returns the callback used to report download progress.
	* @param handle the context handle
	* @return the currently set download callback context
	*/
	option_get_dlcb_ctx :: proc(handle: ^Handle) -> rawptr ---

	/** Sets the callback used to report download progress.
	* @param handle the context handle
	* @param cb the cb to use
	* @param ctx user-provided context to pass to cb
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_dlcb :: proc(handle: ^Handle, cb: Cb_Download, ctx: rawptr) -> i32 ---

	/** Returns the downloading callback.
	* @param handle the context handle
	* @return the currently set fetch callback
	*/
	option_get_fetchcb :: proc(handle: ^Handle) -> Cb_Fetch ---

	/** Returns the downloading callback.
	* @param handle the context handle
	* @return the currently set fetch callback context
	*/
	option_get_fetchcb_ctx :: proc(handle: ^Handle) -> rawptr ---

	/** Sets the downloading callback.
	* @param handle the context handle
	* @param cb the cb to use
	* @param ctx user-provided context to pass to cb
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_fetchcb :: proc(handle: ^Handle, cb: Cb_Fetch, ctx: rawptr) -> i32 ---

	/** Returns the callback used for events.
	* @param handle the context handle
	* @return the currently set event callback
	*/
	option_get_eventcb :: proc(handle: ^Handle) -> Cb_Event ---

	/** Returns the callback used for events.
	* @param handle the context handle
	* @return the currently set event callback context
	*/
	option_get_eventcb_ctx :: proc(handle: ^Handle) -> rawptr ---

	/** Sets the callback used for events.
	* @param handle the context handle
	* @param cb the cb to use
	* @param ctx user-provided context to pass to cb
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_eventcb :: proc(handle: ^Handle, cb: Cb_Event, ctx: rawptr) -> i32 ---

	/** Returns the callback used for questions.
	* @param handle the context handle
	* @return the currently set question callback
	*/
	option_get_questioncb :: proc(handle: ^Handle) -> Cb_Question ---

	/** Returns the callback used for questions.
	* @param handle the context handle
	* @return the currently set question callback context
	*/
	option_get_questioncb_ctx :: proc(handle: ^Handle) -> rawptr ---

	/** Sets the callback used for questions.
	* @param handle the context handle
	* @param cb the cb to use
	* @param ctx user-provided context to pass to cb
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_questioncb :: proc(handle: ^Handle, cb: Cb_Question, ctx: rawptr) -> i32 ---

	/**Returns the callback used for operation progress.
	* @param handle the context handle
	* @return the currently set progress callback
	*/
	option_get_progresscb :: proc(handle: ^Handle) -> Cb_Progress ---

	/**Returns the callback used for operation progress.
	* @param handle the context handle
	* @return the currently set progress callback context
	*/
	option_get_progresscb_ctx :: proc(handle: ^Handle) -> rawptr ---

	/** Sets the callback used for operation progress.
	* @param handle the context handle
	* @param cb the cb to use
	* @param ctx user-provided context to pass to cb
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_progresscb :: proc(handle: ^Handle, cb: Cb_Progress, ctx: rawptr) -> i32 ---

	/** Returns the root path. Read-only.
	* @param handle the context handle
	*/
	option_get_root :: proc(handle: ^Handle) -> cstring ---

	/** Returns the path to the database directory. Read-only.
	* @param handle the context handle
	*/
	option_get_dbpath :: proc(handle: ^Handle) -> cstring ---

	/** Get the name of the database lock file. Read-only.
	* This is the name that the lockfile would have. It does not
	* matter if the lockfile actually exists on disk.
	* @param handle the context handle
	*/
	option_get_lockfile :: proc(handle: ^Handle) -> cstring ---

	/** Gets the currently configured cachedirs,
	* @param handle the context handle
	* @return a char* list of cache directories
	*/
	option_get_cachedirs :: proc(handle: ^Handle) -> ^List ---

	/** Sets the cachedirs.
	* @param handle the context handle
	* @param cachedirs a char* list of cachdirs. The list will be duped and
	* the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_cachedirs :: proc(handle: ^Handle, cachedirs: ^List) -> i32 ---

	/** Append a cachedir to the configured cachedirs.
	* @param handle the context handle
	* @param cachedir the cachedir to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_cachedir :: proc(handle: ^Handle, cachedir: cstring) -> i32 ---

	/** Remove a cachedir from the configured cachedirs.
	* @param handle the context handle
	* @param cachedir the cachedir to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_cachedir :: proc(handle: ^Handle, cachedir: cstring) -> i32 ---

	/** Gets the currently configured hookdirs,
	* @param handle the context handle
	* @return a char* list of hook directories
	*/
	option_get_hookdirs :: proc(handle: ^Handle) -> ^List ---

	/** Sets the hookdirs.
	* @param handle the context handle
	* @param hookdirs a char* list of hookdirs. The list will be duped and
	* the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_hookdirs :: proc(handle: ^Handle, hookdirs: ^List) -> i32 ---

	/** Append a hookdir to the configured hookdirs.
	* @param handle the context handle
	* @param hookdir the hookdir to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_hookdir :: proc(handle: ^Handle, hookdir: cstring) -> i32 ---

	/** Remove a hookdir from the configured hookdirs.
	* @param handle the context handle
	* @param hookdir the hookdir to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_hookdir :: proc(handle: ^Handle, hookdir: cstring) -> i32 ---

	/** Gets the currently configured overwritable files,
	* @param handle the context handle
	* @return a char* list of overwritable file globs
	*/
	option_get_overwrite_files :: proc(handle: ^Handle) -> ^List ---

	/** Sets the overwritable files.
	* @param handle the context handle
	* @param globs a char* list of overwritable file globs. The list will be duped and
	* the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_overwrite_files :: proc(handle: ^Handle, globs: ^List) -> i32 ---

	/** Append an overwritable file to the configured overwritable files.
	* @param handle the context handle
	* @param glob the file glob to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_overwrite_file :: proc(handle: ^Handle, glob: cstring) -> i32 ---

	/** Remove a file glob from the configured overwritable files globs.
	* @note The overwritable file list contains a list of globs. The glob to
	* remove must exactly match the entry to remove. There is no glob expansion.
	* @param handle the context handle
	* @param glob the file glob to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_overwrite_file :: proc(handle: ^Handle, glob: cstring) -> i32 ---

	/** Gets the filepath to the currently set logfile.
	* @param handle the context handle
	* @return the path to the logfile
	*/
	option_get_logfile :: proc(handle: ^Handle) -> cstring ---

	/** Sets the logfile path.
	* @param handle the context handle
	* @param logfile path to the new location of the logfile
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_logfile :: proc(handle: ^Handle, logfile: cstring) -> i32 ---

	/** Returns the path to libalpm's GnuPG home directory.
	* @param handle the context handle
	* @return the path to libalpms's GnuPG home directory
	*/
	option_get_gpgdir :: proc(handle: ^Handle) -> cstring ---

	/** Sets the path to libalpm's GnuPG home directory.
	* @param handle the context handle
	* @param gpgdir the gpgdir to set
	*/
	option_set_gpgdir :: proc(handle: ^Handle, gpgdir: cstring) -> i32 ---

	/** Returns the user to switch to for sensitive operations.
	* @return the user name
	*/
	option_get_sandboxuser :: proc(handle: ^Handle) -> cstring ---

	/** Sets the user to switch to for sensitive operations.
	* @param handle the context handle
	* @param sandboxuser the user to set
	*/
	option_set_sandboxuser :: proc(handle: ^Handle, sandboxuser: cstring) -> i32 ---

	/** Returns whether to use syslog (0 is FALSE, TRUE otherwise).
	* @param handle the context handle
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_get_usesyslog :: proc(handle: ^Handle) -> i32 ---

	/** Sets whether to use syslog (0 is FALSE, TRUE otherwise).
	* @param handle the context handle
	* @param usesyslog whether to use the syslog (0 is FALSE, TRUE otherwise)
	*/
	option_set_usesyslog :: proc(handle: ^Handle, usesyslog: i32) -> i32 ---

	/** Get the list of no-upgrade files
	* @param handle the context handle
	* @return the char* list of no-upgrade files
	*/
	option_get_noupgrades :: proc(handle: ^Handle) -> ^List ---

	/** Add a file to the no-upgrade list
	* @param handle the context handle
	* @param path the path to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_noupgrade :: proc(handle: ^Handle, path: cstring) -> i32 ---

	/** Sets the list of no-upgrade files
	* @param handle the context handle
	* @param noupgrade a char* list of file to not upgrade.
	* The list will be duped and the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_noupgrades :: proc(handle: ^Handle, noupgrade: ^List) -> i32 ---

	/** Remove an entry from the no-upgrade list
	* @param handle the context handle
	* @param path the path to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_noupgrade :: proc(handle: ^Handle, path: cstring) -> i32 ---

	/** Test if a path matches any of the globs in the no-upgrade list
	* @param handle the context handle
	* @param path the path to test
	* @return 0 is the path matches a glob, negative if there is no match and
	* positive is the  match was inverted
	*/
	option_match_noupgrade :: proc(handle: ^Handle, path: cstring) -> i32 ---

	/** Get the list of no-extract files
	* @param handle the context handle
	* @return the char* list of no-extract files
	*/
	option_get_noextracts :: proc(handle: ^Handle) -> ^List ---

	/** Add a file to the no-extract list
	* @param handle the context handle
	* @param path the path to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_noextract :: proc(handle: ^Handle, path: cstring) -> i32 ---

	/** Sets the list of no-extract files
	* @param handle the context handle
	* @param noextract a char* list of file to not extract.
	* The list will be duped and the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_noextracts :: proc(handle: ^Handle, noextract: ^List) -> i32 ---

	/** Remove an entry from the no-extract list
	* @param handle the context handle
	* @param path the path to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_noextract :: proc(handle: ^Handle, path: cstring) -> i32 ---

	/** Test if a path matches any of the globs in the no-extract list
	* @param handle the context handle
	* @param path the path to test
	* @return 0 is the path matches a glob, negative if there is no match and
	* positive is the  match was inverted
	*/
	option_match_noextract :: proc(handle: ^Handle, path: cstring) -> i32 ---

	/** Get the list of ignored packages
	* @param handle the context handle
	* @return the char* list of ignored packages
	*/
	option_get_ignorepkgs :: proc(handle: ^Handle) -> ^List ---

	/** Add a file to the ignored package list
	* @param handle the context handle
	* @param pkg the package to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_ignorepkg :: proc(handle: ^Handle, pkg: cstring) -> i32 ---

	/** Sets the list of packages to ignore
	* @param handle the context handle
	* @param ignorepkgs a char* list of packages to ignore
	* The list will be duped and the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_ignorepkgs :: proc(handle: ^Handle, ignorepkgs: ^List) -> i32 ---

	/** Remove an entry from the ignorepkg list
	* @param handle the context handle
	* @param pkg the package to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_ignorepkg :: proc(handle: ^Handle, pkg: cstring) -> i32 ---

	/** Get the list of ignored groups
	* @param handle the context handle
	* @return the char* list of ignored groups
	*/
	option_get_ignoregroups :: proc(handle: ^Handle) -> ^List ---

	/** Add a file to the ignored group list
	* @param handle the context handle
	* @param grp the group to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_ignoregroup :: proc(handle: ^Handle, grp: cstring) -> i32 ---

	/** Sets the list of groups to ignore
	* @param handle the context handle
	* @param ignoregrps a char* list of groups to ignore
	* The list will be duped and the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_ignoregroups :: proc(handle: ^Handle, ignoregrps: ^List) -> i32 ---

	/** Remove an entry from the ignoregroup list
	* @param handle the context handle
	* @param grp the group to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_ignoregroup :: proc(handle: ^Handle, grp: cstring) -> i32 ---

	/** Gets the list of dependencies that are assumed to be met
	* @param handle the context handle
	* @return a list of alpm_depend_t*
	*/
	option_get_assumeinstalled :: proc(handle: ^Handle) -> ^List ---

	/** Add a depend to the assumed installed list
	* @param handle the context handle
	* @param dep the dependency to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_add_assumeinstalled :: proc(handle: ^Handle, dep: ^Depend) -> i32 ---

	/** Sets the list of dependencies that are assumed to be met
	* @param handle the context handle
	* @param deps a list of *alpm_depend_t
	* The list will be duped and the original will still need to be freed by the caller.
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_assumeinstalled :: proc(handle: ^Handle, deps: ^List) -> i32 ---

	/** Remove an entry from the assume installed list
	* @param handle the context handle
	* @param dep the dep to remove
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_remove_assumeinstalled :: proc(handle: ^Handle, dep: ^Depend) -> i32 ---

	/** Returns the allowed package architecture.
	* @param handle the context handle
	* @return the configured package architectures
	*/
	option_get_architectures :: proc(handle: ^Handle) -> ^List ---

	/** Adds an allowed package architecture.
	* @param handle the context handle
	* @param arch the architecture to set
	*/
	option_add_architecture :: proc(handle: ^Handle, arch: cstring) -> i32 ---

	/** Sets the allowed package architecture.
	* @param handle the context handle
	* @param arches the architecture to set
	*/
	option_set_architectures :: proc(handle: ^Handle, arches: ^List) -> i32 ---

	/** Removes an allowed package architecture.
	* @param handle the context handle
	* @param arch the architecture to remove
	*/
	option_remove_architecture :: proc(handle: ^Handle, arch: cstring) -> i32 ---

	/** Get whether or not checking for free space before installing packages is enabled.
	* @param handle the context handle
	* @return 0 if disabled, 1 if enabled
	*/
	option_get_checkspace :: proc(handle: ^Handle) -> i32 ---

	/** Enable/disable checking free space before installing packages.
	* @param handle the context handle
	* @param checkspace 0 for disabled, 1 for enabled
	*/
	option_set_checkspace :: proc(handle: ^Handle, checkspace: i32) -> i32 ---

	/** Gets the configured database extension.
	* @param handle the context handle
	* @return the configured database extension
	*/
	option_get_dbext :: proc(handle: ^Handle) -> cstring ---

	/** Sets the database extension.
	* @param handle the context handle
	* @param dbext the database extension to use
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_dbext :: proc(handle: ^Handle, dbext: cstring) -> i32 ---

	/** Get the default siglevel.
	* @param handle the context handle
	* @return a \link alpm_siglevel_t \endlink bitfield of the siglevel
	*/
	option_get_default_siglevel :: proc(handle: ^Handle) -> i32 ---

	/** Set the default siglevel.
	* @param handle the context handle
	* @param level a \link alpm_siglevel_t \endlink bitfield of the level to set
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_default_siglevel :: proc(handle: ^Handle, level: i32) -> i32 ---

	/** Get the configured local file siglevel.
	* @param handle the context handle
	* @return a \link alpm_siglevel_t \endlink bitfield of the siglevel
	*/
	option_get_local_file_siglevel :: proc(handle: ^Handle) -> i32 ---

	/** Set the local file siglevel.
	* @param handle the context handle
	* @param level a \link alpm_siglevel_t \endlink bitfield of the level to set
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_local_file_siglevel :: proc(handle: ^Handle, level: i32) -> i32 ---

	/** Get the configured remote file siglevel.
	* @param handle the context handle
	* @return a \link alpm_siglevel_t \endlink bitfield of the siglevel
	*/
	option_get_remote_file_siglevel :: proc(handle: ^Handle) -> i32 ---

	/** Set the remote file siglevel.
	* @param handle the context handle
	* @param level a \link alpm_siglevel_t \endlink bitfield of the level to set
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_remote_file_siglevel :: proc(handle: ^Handle, level: i32) -> i32 ---

	/** Enables/disables the download timeout.
	* @param handle the context handle
	* @param disable_dl_timeout 0 for enabled, 1 for disabled
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_disable_dl_timeout :: proc(handle: ^Handle, disable_dl_timeout: u16) -> i32 ---

	/** Gets the number of parallel streams to download database and package files.
	* @param handle the context handle
	* @return the number of parallel streams to download database and package files
	*/
	option_get_parallel_downloads :: proc(handle: ^Handle) -> i32 ---

	/** Sets number of parallel streams to download database and package files.
	* @param handle the context handle
	* @param num_streams number of parallel download streams
	* @return 0 on success, -1 on error
	*/
	option_set_parallel_downloads :: proc(handle: ^Handle, num_streams: u32) -> i32 ---

	/** Enables/disables the sandbox.
	* @param handle the context handle
	* @param disable_sandbox 0 for enabled, 1 for disabled
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	option_set_disable_sandbox :: proc(handle: ^Handle, disable_sandbox: u16) -> i32 ---
}

/** Package install reasons. */
_Alpm_Pkgreason :: enum u32 {
	/** Explicitly requested by the user. */
	EXPLICIT = 0,

	/** Installed as a dependency for another package. */
	DEPEND   = 1,

	/** Failed parsing of local database */
	UNKNOWN  = 2,
}

/** Package install reasons. */
Pkgreason :: _Alpm_Pkgreason

/** Location a package object was loaded from. */
_Alpm_Pkgfrom :: enum u32 {
	/** Loaded from a file via \link alpm_pkg_load \endlink */
	FILE    = 1,

	/** From the local database */
	LOCALDB = 2,

	/** From a sync database */
	SYNCDB  = 3,
}

/** Location a package object was loaded from. */
Pkgfrom :: _Alpm_Pkgfrom

/** Method used to validate a package. */
_Alpm_Pkgvalidation :: enum u32 {
	/** The package's validation type is unknown */
	UNKNOWN   = 0,

	/** The package does not have any validation */
	NONE      = 1,

	/** The package is validated with md5 */
	MD5SUM    = 2,

	/** The package is validated with sha256 */
	SHA256SUM = 4,

	/** The package is validated with a PGP signature */
	SIGNATURE = 8,
}

/** Method used to validate a package. */
Pkgvalidation :: _Alpm_Pkgvalidation

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Create a package from a file.
	* If full is false, the archive is read only until all necessary
	* metadata is found. If it is true, the entire archive is read, which
	* serves as a verification of integrity and the filelist can be created.
	* The allocated structure should be freed using alpm_pkg_free().
	* @param handle the context handle
	* @param filename location of the package tarball
	* @param full whether to stop the load after metadata is read or continue
	* through the full archive
	* @param level what level of package signature checking to perform on the
	* package; note that this must be a '.sig' file type verification
	* @param pkg address of the package pointer
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	pkg_load :: proc(handle: ^Handle, filename: cstring, full: i32, level: i32, pkg: ^^Pkg) -> i32 ---

	/** Fetch a list of remote packages.
	* @param handle the context handle
	* @param urls list of package URLs to download
	* @param fetched list of filepaths to the fetched packages, each item
	*    corresponds to one in `urls` list. This is an output parameter,
	*    the caller should provide a pointer to an empty list
	*    (*fetched === NULL) and the callee fills the list with data.
	* @return 0 on success or -1 on failure
	*/
	fetch_pkgurl :: proc(handle: ^Handle, urls: ^List, fetched: ^^List) -> i32 ---

	/** Find a package in a list by name.
	* @param haystack a list of alpm_pkg_t
	* @param needle the package name
	* @return a pointer to the package if found or NULL
	*/
	pkg_find :: proc(haystack: ^List, needle: cstring) -> ^Pkg ---

	/** Free a package.
	* Only packages loaded with \link alpm_pkg_load \endlink can be freed.
	* Packages from databases will be freed by libalpm when they are unregistered.
	* @param pkg package pointer to free
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	pkg_free :: proc(pkg: ^Pkg) -> i32 ---

	/** Check the integrity (with md5) of a package from the sync cache.
	* @param pkg package pointer
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	pkg_checkmd5sum :: proc(pkg: ^Pkg) -> i32 ---

	/** Compare two version strings and determine which one is 'newer'.
	* Returns a value comparable to the way strcmp works. Returns 1
	* if a is newer than b, 0 if a and b are the same version, or -1
	* if b is newer than a.
	*
	* Different epoch values for version strings will override any further
	* comparison. If no epoch is provided, 0 is assumed.
	*
	* Keep in mind that the pkgrel is only compared if it is available
	* on both versions handed to this function. For example, comparing
	* 1.5-1 and 1.5 will yield 0; comparing 1.5-1 and 1.5-2 will yield
	* -1 as expected. This is mainly for supporting versioned dependencies
	* that do not include the pkgrel.
	*/
	pkg_vercmp :: proc(a: cstring, b: cstring) -> i32 ---

	/** Computes the list of packages requiring a given package.
	* The return value of this function is a newly allocated
	* list of package names (char*), it should be freed by the caller.
	* @param pkg a package
	* @return the list of packages requiring pkg
	*/
	pkg_compute_requiredby :: proc(pkg: ^Pkg) -> ^List ---

	/** Computes the list of packages optionally requiring a given package.
	* The return value of this function is a newly allocated
	* list of package names (char*), it should be freed by the caller.
	* @param pkg a package
	* @return the list of packages optionally requiring pkg
	*/
	pkg_compute_optionalfor :: proc(pkg: ^Pkg) -> ^List ---

	/** Test if a package should be ignored.
	* Checks if the package is ignored via IgnorePkg, or if the package is
	* in a group ignored via IgnoreGroup.
	* @param handle the context handle
	* @param pkg the package to test
	* @return 1 if the package should be ignored, 0 otherwise
	*/
	pkg_should_ignore :: proc(handle: ^Handle, pkg: ^Pkg) -> i32 ---

	/** Gets the handle of a package
	* @param pkg a pointer to package
	* @return the alpm handle that the package belongs to
	*/
	pkg_get_handle :: proc(pkg: ^Pkg) -> ^Handle ---

	/** Gets the name of the file from which the package was loaded.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_filename :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the package base name.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_base :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the package name.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_name :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the package version as a string.
	* This includes all available epoch, version, and pkgrel components. Use
	* alpm_pkg_vercmp() to compare version strings if necessary.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_version :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the origin of the package.
	* @return an alpm_pkgfrom_t constant, -1 on error
	*/
	pkg_get_origin :: proc(pkg: ^Pkg) -> Pkgfrom ---

	/** Returns the package description.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_desc :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the package URL.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_url :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the build timestamp of the package.
	* @param pkg a pointer to package
	* @return the timestamp of the build time
	*/
	pkg_get_builddate :: proc(pkg: ^Pkg) -> Time ---

	/** Returns the install timestamp of the package.
	* @param pkg a pointer to package
	* @return the timestamp of the install time
	*/
	pkg_get_installdate :: proc(pkg: ^Pkg) -> Time ---

	/** Returns the packager's name.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_packager :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the package's MD5 checksum as a string.
	* The returned string is a sequence of 32 lowercase hexadecimal digits.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_md5sum :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the package's SHA256 checksum as a string.
	* The returned string is a sequence of 64 lowercase hexadecimal digits.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_sha256sum :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the architecture for which the package was built.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_arch :: proc(pkg: ^Pkg) -> cstring ---

	/** Returns the size of the package. This is only available for sync database
	* packages and package files, not those loaded from the local database.
	* @param pkg a pointer to package
	* @return the size of the package in bytes.
	*/
	pkg_get_size :: proc(pkg: ^Pkg) -> posix.off_t ---

	/** Returns the installed size of the package.
	* @param pkg a pointer to package
	* @return the total size of files installed by the package.
	*/
	pkg_get_isize :: proc(pkg: ^Pkg) -> posix.off_t ---

	/** Returns the package installation reason.
	* @param pkg a pointer to package
	* @return an enum member giving the install reason.
	*/
	pkg_get_reason :: proc(pkg: ^Pkg) -> Pkgreason ---

	/** Returns the list of package licenses.
	* @param pkg a pointer to package
	* @return a pointer to an internal list of strings.
	*/
	pkg_get_licenses :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the list of package groups.
	* @param pkg a pointer to package
	* @return a pointer to an internal list of strings.
	*/
	pkg_get_groups :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the list of package dependencies as alpm_depend_t.
	* @param pkg a pointer to package
	* @return a reference to an internal list of alpm_depend_t structures.
	*/
	pkg_get_depends :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the list of package optional dependencies.
	* @param pkg a pointer to package
	* @return a reference to an internal list of alpm_depend_t structures.
	*/
	pkg_get_optdepends :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns a list of package check dependencies
	* @param pkg a pointer to package
	* @return a reference to an internal list of alpm_depend_t structures.
	*/
	pkg_get_checkdepends :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns a list of package make dependencies
	* @param pkg a pointer to package
	* @return a reference to an internal list of alpm_depend_t structures.
	*/
	pkg_get_makedepends :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the list of packages conflicting with pkg.
	* @param pkg a pointer to package
	* @return a reference to an internal list of alpm_depend_t structures.
	*/
	pkg_get_conflicts :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the list of packages provided by pkg.
	* @param pkg a pointer to package
	* @return a reference to an internal list of alpm_depend_t structures.
	*/
	pkg_get_provides :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the list of packages to be replaced by pkg.
	* @param pkg a pointer to package
	* @return a reference to an internal list of alpm_depend_t structures.
	*/
	pkg_get_replaces :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the list of files installed by pkg.
	* The filenames are relative to the install root,
	* and do not include leading slashes.
	* @param pkg a pointer to package
	* @return a pointer to a filelist object containing a count and an array of
	* package file objects
	*/
	pkg_get_files :: proc(pkg: ^Pkg) -> ^Filelist ---

	/** Returns the list of files backed up when installing pkg.
	* @param pkg a pointer to package
	* @return a reference to a list of alpm_backup_t objects
	*/
	pkg_get_backup :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns the database containing pkg.
	* Returns a pointer to the alpm_db_t structure the package is
	* originating from, or NULL if the package was loaded from a file.
	* @param pkg a pointer to package
	* @return a pointer to the DB containing pkg, or NULL.
	*/
	pkg_get_db :: proc(pkg: ^Pkg) -> ^Db ---

	/** Returns the base64 encoded package signature.
	* @param pkg a pointer to package
	* @return a reference to an internal string
	*/
	pkg_get_base64_sig :: proc(pkg: ^Pkg) -> cstring ---

	/** Extracts package signature either from embedded package signature
	* or if it is absent then reads data from detached signature file.
	* @param pkg a pointer to package.
	* @param sig output parameter for signature data. Callee function allocates
	* a buffer needed for the signature data. Caller is responsible for
	* freeing this buffer.
	* @param sig_len output parameter for the signature data length.
	* @return 0 on success, negative number on error.
	*/
	pkg_get_sig :: proc(pkg: ^Pkg, sig: ^^u8, sig_len: ^i32) -> i32 ---

	/** Returns the method used to validate a package during install.
	* @param pkg a pointer to package
	* @return an enum member giving the validation method
	*/
	pkg_get_validation :: proc(pkg: ^Pkg) -> i32 ---

	/** Gets the extended data field of a package.
	* @param pkg a pointer to package
	* @return a reference to a list of alpm_pkg_xdata_t objects
	*/
	pkg_get_xdata :: proc(pkg: ^Pkg) -> ^List ---

	/** Returns whether the package has an install scriptlet.
	* @return 0 if FALSE, TRUE otherwise
	*/
	pkg_has_scriptlet :: proc(pkg: ^Pkg) -> i32 ---

	/** Returns the size of the files that will be downloaded to install a
	* package.
	* @param newpkg the new package to upgrade to
	* @return the size of the download
	*/
	pkg_download_size :: proc(newpkg: ^Pkg) -> posix.off_t ---

	/** Set install reason for a package in the local database.
	* The provided package object must be from the local database or this method
	* will fail. The write to the local database is performed immediately.
	* @param pkg the package to update
	* @param reason the new install reason
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	pkg_set_reason :: proc(pkg: ^Pkg, reason: Pkgreason) -> i32 ---

	/** Open a package changelog for reading.
	* Similar to fopen in functionality, except that the returned 'file
	* stream' could really be from an archive as well as from the database.
	* @param pkg the package to read the changelog of (either file or db)
	* @return a 'file stream' to the package changelog
	*/
	pkg_changelog_open :: proc(pkg: ^Pkg) -> rawptr ---

	/** Read data from an open changelog 'file stream'.
	* Similar to fread in functionality, this function takes a buffer and
	* amount of data to read. If an error occurs pm_errno will be set.
	* @param ptr a buffer to fill with raw changelog data
	* @param size the size of the buffer
	* @param pkg the package that the changelog is being read from
	* @param fp a 'file stream' to the package changelog
	* @return the number of characters read, or 0 if there is no more data or an
	* error occurred.
	*/
	pkg_changelog_read :: proc(ptr: rawptr, size: i32, pkg: ^Pkg, fp: rawptr) -> i32 ---

	/** Close a package changelog for reading.
	* @param pkg the package to close the changelog of (either file or db)
	* @param fp the 'file stream' to the package changelog to close
	* @return 0 on success, -1 on error
	*/
	pkg_changelog_close :: proc(pkg: ^Pkg, fp: rawptr) -> i32 ---

	/** Open a package mtree file for reading.
	* @param pkg the local package to read the mtree of
	* @return an archive structure for the package mtree file
	*/
	pkg_mtree_open :: proc(pkg: ^Pkg) -> ^Archive ---

	/** Read next entry from a package mtree file.
	* @param pkg the package that the mtree file is being read from
	* @param archive the archive structure reading from the mtree file
	* @param entry an archive_entry to store the entry header information
	* @return 0 on success, 1 if end of archive is reached, -1 otherwise.
	*/
	pkg_mtree_next :: proc(pkg: ^Pkg, archive: ^Archive, entry: ^^Archive_Entry) -> i32 ---

	/** Close a package mtree file.
	* @param pkg the local package to close the mtree of
	* @param archive the archive to close
	*/
	pkg_mtree_close :: proc(pkg: ^Pkg, archive: ^Archive) -> i32 ---
}

/** Transaction flags */
_Alpm_Transflag :: enum u32 {
	/** Ignore dependency checks. */
	NODEPS       = 1,

	/* (1 << 1) flag can go here */
	/** Delete files even if they are tagged as backup. */
	NOSAVE       = 4,

	/** Ignore version numbers when checking dependencies. */
	NODEPVERSION = 8,

	/** Remove also any packages depending on a package being removed. */
	CASCADE      = 16,

	/** Remove packages and their unneeded deps (not explicitly installed). */
	RECURSE      = 32,

	/** Modify database but do not commit changes to the filesystem. */
	DBONLY       = 64,

	/** Do not run hooks during a transaction */
	NOHOOKS      = 128,

	/** Use ALPM_PKG_REASON_DEPEND when installing packages. */
	ALLDEPS      = 256,

	/** Only download packages and do not actually install. */
	DOWNLOADONLY = 512,

	/** Do not execute install scriptlets after installing. */
	NOSCRIPTLET  = 1024,

	/** Ignore dependency conflicts. */
	NOCONFLICTS  = 2048,

	/* (1 << 12) flag can go here */
	/** Do not install a package if it is already installed and up to date. */
	NEEDED       = 8192,

	/** Use ALPM_PKG_REASON_EXPLICIT when installing packages. */
	ALLEXPLICIT  = 16384,

	/** Do not remove a package if it is needed by another one. */
	UNNEEDED     = 32768,

	/** Remove also explicitly installed unneeded deps (use with ALPM_TRANS_FLAG_RECURSE). */
	RECURSEALL   = 65536,

	/** Do not lock the database during the operation. */
	NOLOCK       = 131072,
}

/** Transaction flags */
Transflag :: _Alpm_Transflag

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Returns the bitfield of flags for the current transaction.
	* @param handle the context handle
	* @return the bitfield of transaction flags
	*/
	trans_get_flags :: proc(handle: ^Handle) -> i32 ---

	/** Returns a list of packages added by the transaction.
	* @param handle the context handle
	* @return a list of alpm_pkg_t structures
	*/
	trans_get_add :: proc(handle: ^Handle) -> ^List ---

	/** Returns the list of packages removed by the transaction.
	* @param handle the context handle
	* @return a list of alpm_pkg_t structures
	*/
	trans_get_remove :: proc(handle: ^Handle) -> ^List ---

	/** Initialize the transaction.
	* @param handle the context handle
	* @param flags flags of the transaction (like nodeps, etc; see alpm_transflag_t)
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	trans_init :: proc(handle: ^Handle, flags: i32) -> i32 ---

	/** Prepare a transaction.
	* @param handle the context handle
	* @param data the address of an alpm_list where a list
	* of alpm_depmissing_t objects is dumped (conflicting packages)
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	trans_prepare :: proc(handle: ^Handle, data: ^^List) -> i32 ---

	/** Commit a transaction.
	* @param handle the context handle
	* @param data the address of an alpm_list where detailed description
	* of an error can be dumped (i.e. list of conflicting files)
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	trans_commit :: proc(handle: ^Handle, data: ^^List) -> i32 ---

	/** Interrupt a transaction.
	* @param handle the context handle
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	trans_interrupt :: proc(handle: ^Handle) -> i32 ---

	/** Release a transaction.
	* @param handle the context handle
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	trans_release :: proc(handle: ^Handle) -> i32 ---

	/** Search for packages to upgrade and add them to the transaction.
	* @param handle the context handle
	* @param enable_downgrade allow downgrading of packages if the remote version is lower
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	sync_sysupgrade :: proc(handle: ^Handle, enable_downgrade: i32) -> i32 ---

	/** Add a package to the transaction.
	* If the package was loaded by alpm_pkg_load(), it will be freed upon
	* \link alpm_trans_release \endlink invocation.
	* @param handle the context handle
	* @param pkg the package to add
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	add_pkg :: proc(handle: ^Handle, pkg: ^Pkg) -> i32 ---

	/** Add a package removal to the transaction.
	* @param handle the context handle
	* @param pkg the package to uninstall
	* @return 0 on success, -1 on error (pm_errno is set accordingly)
	*/
	remove_pkg :: proc(handle: ^Handle, pkg: ^Pkg) -> i32 ---

	/** Check for new version of pkg in syncdbs.
	*
	* If the same package appears multiple dbs only the first will be checked
	*
	* This only checks the syncdb for a newer version. It does not access the network at all.
	* See \link alpm_db_update \endlink to update a database.
	*/
	sync_get_new_version :: proc(pkg: ^Pkg, dbs_sync: ^List) -> ^Pkg ---

	/** Get the md5 sum of file.
	* @param filename name of the file
	* @return the checksum on success, NULL on error
	*/
	compute_md5sum :: proc(filename: cstring) -> cstring ---

	/** Get the sha256 sum of file.
	* @param filename name of the file
	* @return the checksum on success, NULL on error
	*/
	compute_sha256sum :: proc(filename: cstring) -> cstring ---

	/** Remove the database lock file
	* @param handle the context handle
	* @return 0 on success, -1 on error
	*
	* @note Safe to call from inside signal handlers.
	*/
	unlock :: proc(handle: ^Handle) -> i32 ---
}

/** Enum of possible compile time features */
Caps :: enum u32 {
	/** localization */
	NLS        = 1,

	/** Ability to download */
	DOWNLOADER = 2,

	/** Signature checking */
	SIGNATURES = 4,
}

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Get the version of library.
	* @return the library version, e.g. "6.0.4"
	* */
	version :: proc() -> cstring ---

	/** Get the capabilities of the library.
	* @return a bitmask of the capabilities
	* */
	capabilities :: proc() -> i32 ---

	/** Drop privileges by switching to a different user.
	* @param handle the context handle
	* @param sandboxuser the user to switch to
	* @param sandbox_path if non-NULL, restrict writes to this filesystem path
	* @param restrict_syscalls whether to deny access to a list of dangerous syscalls
	* @return 0 on success, -1 on failure
	*/
	sandbox_setup_child :: proc(handle: ^Handle, sandboxuser: cstring, sandbox_path: cstring, restrict_syscalls: i32) -> i32 ---
}

