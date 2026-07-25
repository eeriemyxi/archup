package alpm

foreign import alpm "system:alpm"

Handle :: distinct rawptr
Db :: distinct rawptr
Pkg :: distinct rawptr
List :: struct {
	data: rawptr,
	prev: ^List,
	next: ^List,
}
Off :: distinct i64
Errno :: distinct enum {
	/** No error */
	OK = 0,
	/** Failed to allocate memory */
	MEMORY,
	/** A system error occurred */
	SYSTEM,
	/** Permmision denied */
	BADPERMS,
	/** Should be a file */
	NOT_A_FILE,
	/** Should be a directory */
	NOT_A_DIR,
	/** Function was called with invalid arguments */
	WRONG_ARGS,
	/** Insufficient disk space */
	DISK_SPACE,
	/* Interface */
	/** Handle should be null */
	HANDLE_NULL,
	/** Handle should not be null */
	HANDLE_NOT_NULL,
	/** Failed to acquire lock */
	HANDLE_LOCK,
	/* Databases */
	/** Failed to open database */
	DB_OPEN,
	/** Failed to create database */
	DB_CREATE,
	/** Database should not be null */
	DB_NULL,
	/** Database should be null */
	DB_NOT_NULL,
	/** The database could not be found */
	DB_NOT_FOUND,
	/** Database is invalid */
	DB_INVALID,
	/** Database has an invalid signature */
	DB_INVALID_SIG,
	/** The localdb is in a newer/older format than libalpm expects */
	DB_VERSION,
	/** Failed to write to the database */
	DB_WRITE,
	/** Failed to remove entry from database */
	DB_REMOVE,
	/* Servers */
	/** Server URL is in an invalid format */
	SERVER_BAD_URL,
	/** The database has no configured servers */
	SERVER_NONE,
	/* Transactions */
	/** A transaction is already initialized */
	TRANS_NOT_NULL,
	/** A transaction has not been initialized */
	TRANS_NULL,
	/** Duplicate target in transaction */
	TRANS_DUP_TARGET,
	/** Duplicate filename in transaction */
	TRANS_DUP_FILENAME,
	/** A transaction has not been initialized */
	TRANS_NOT_INITIALIZED,
	/** Transaction has not been prepared */
	TRANS_NOT_PREPARED,
	/** Transaction was aborted */
	TRANS_ABORT,
	/** Failed to interrupt transaction */
	TRANS_TYPE,
	/** Tried to commit transaction without locking the database */
	TRANS_NOT_LOCKED,
	/** A hook failed to run */
	TRANS_HOOK_FAILED,
	/* Packages */
	/** Package not found */
	PKG_NOT_FOUND,
	/** Package is in ignorepkg */
	PKG_IGNORED,
	/** Package is invalid */
	PKG_INVALID,
	/** Package has an invalid checksum */
	PKG_INVALID_CHECKSUM,
	/** Package has an invalid signature */
	PKG_INVALID_SIG,
	/** Package does not have a signature */
	PKG_MISSING_SIG,
	/** Cannot open the package file */
	PKG_OPEN,
	/** Failed to remove package files */
	PKG_CANT_REMOVE,
	/** Package has an invalid name */
	PKG_INVALID_NAME,
	/** Package has an invalid architecture */
	PKG_INVALID_ARCH,
	/* Signatures */
	/** Signatures are missing */
	SIG_MISSING,
	/** Signatures are invalid */
	SIG_INVALID,
	/* Dependencies */
	/** Dependencies could not be satisfied */
	UNSATISFIED_DEPS,
	/** Conflicting dependencies */
	CONFLICTING_DEPS,
	/** Files conflict */
	FILE_CONFLICTS,
	/* Misc */
	/** Download failed */
	RETRIEVE,
	/** Invalid Regex */
	INVALID_REGEX,
	/* External library errors */
	/** Error in libarchive */
	LIBARCHIVE,
	/** Error in libcurl */
	LIBCURL,
	/** Error in external download program */
	EXTERNAL_DOWNLOAD,
	/** Error in gpgme */
	GPGME,
	/** Missing compile-time features */
	MISSING_CAPABILITY_SIGNATURES
}

@(link_prefix = "alpm_")
@(default_calling_convention = "system")
foreign alpm {
	initialize :: proc(root: cstring, dbpath: cstring, err: ^Errno) -> Handle ---
	// option_set_dbpath :: proc(handle: Handle, dbpath: cstring) -> i32 ---
	get_localdb :: proc(handle: Handle) -> Db ---
	get_syncdbs :: proc(handle: Handle) -> ^List ---
	db_get_pkgcache :: proc(db: Db) -> ^List ---
	find_satisfier :: proc(dbs: ^List, depstring: cstring) -> Pkg ---
	find_dbs_satisfier :: proc(handle: Handle, dbs: ^List, depstring: cstring) -> Pkg ---
	pkg_vercmp :: proc(a: cstring, b: cstring) -> i32 ---
	pkg_get_name :: proc(pkg: Pkg) -> cstring ---
	pkg_get_version :: proc(pkg: Pkg) -> cstring ---
	pkg_download_size :: proc(pkg: Pkg) -> Off ---
	pkg_get_isize :: proc(pkg: Pkg) -> Off ---
	register_syncdb :: proc(handle: Handle, treename: cstring, level: i32) -> Db ---
}
