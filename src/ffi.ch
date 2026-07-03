public namespace mongodb {

public struct ffi {
    @extern
    func mongoc_get_version() : *char;

    // --- BSON ---

    @extern
    func bson_new() : *mut bson_t;

    @extern
    func bson_new_from_data(data : *u8, length : size_t) : *mut bson_t;

    @extern
    func bson_init(b : *mut bson_t) : void;

    @extern
    func bson_destroy(b : *mut bson_t) : void;

    @extern
    func bson_as_canonical_extended_json(b : *mut bson_t, length : *mut size_t) : *mut char;

    @extern
    func bson_as_relaxed_extended_json(b : *mut bson_t, length : *mut size_t) : *mut char;

    @extern
    func bson_free(ptr : *mut void) : void;

    @extern
    func bson_append_utf8(b : *mut bson_t, key : *char, key_len : int, value : *char, val_len : int) : bool;

    @extern
    func bson_append_int32(b : *mut bson_t, key : *char, key_len : int, value : i32) : bool;

    @extern
    func bson_append_int64(b : *mut bson_t, key : *char, key_len : int, value : i64) : bool;

    @extern
    func bson_append_double(b : *mut bson_t, key : *char, key_len : int, value : double) : bool;

    @extern
    func bson_append_bool(b : *mut bson_t, key : *char, key_len : int, value : bool) : bool;

    @extern
    func bson_append_null(b : *mut bson_t, key : *char, key_len : int) : bool;

    @extern
    func bson_append_regex(b : *mut bson_t, key : *char, key_len : int, regex : *char, options : *char) : bool;

    @extern
    func bson_append_timestamp(b : *mut bson_t, key : *char, key_len : int, timestamp : u32, increment : u32) : bool;

    @extern
    func bson_append_oid(b : *mut bson_t, key : *char, key_len : int, oid : *bson_oid_t) : bool;

    @extern
    func bson_append_document(b : *mut bson_t, key : *char, key_len : int, value : *bson_t) : bool;

    @extern
    func bson_append_array(b : *mut bson_t, key : *char, key_len : int, value : *bson_t) : bool;

    @extern
    func bson_oid_init(oid : *mut bson_oid_t, context : *mut void) : void;

    @extern
    func bson_oid_to_string(oid : *bson_oid_t, str : *mut char) : void;

    @extern
    func bson_oid_init_from_string(oid : *mut bson_oid_t, str : *char) : void;

    @extern
    func bson_iter_init(iter : *mut bson_iter_t, b : *bson_t) : bool;

    @extern
    func bson_iter_next(iter : *mut bson_iter_t) : bool;

    @extern
    func bson_iter_key(iter : *bson_iter_t) : *char;

    @extern
    func bson_iter_type(iter : *bson_iter_t) : int;

    @extern
    func bson_iter_int32(iter : *bson_iter_t) : i32;

    @extern
    func bson_iter_int64(iter : *bson_iter_t) : i64;

    @extern
    func bson_iter_double(iter : *bson_iter_t) : double;

    @extern
    func bson_iter_bool(iter : *bson_iter_t) : bool;

    @extern
    func bson_iter_utf8(iter : *bson_iter_t, length : *mut u32) : *char;

    @extern
    func bson_iter_oid(iter : *bson_iter_t) : *bson_oid_t;

    @extern
    func bson_iter_document(iter : *bson_iter_t, length : *mut u32, data : **u8) : void;

    @extern
    func bson_iter_array(iter : *bson_iter_t, length : *mut u32, data : **u8) : void;

    @extern
    func bson_strfreev(strv : **char) : void;

    @extern
    func bson_new_from_json(data : *u8, len : isize, error : *mut bson_error_t) : *mut bson_t;

    @extern
    func bson_copy(src : *bson_t) : *mut bson_t;

    @extern
    func bson_iter_init_find(iter : *mut bson_iter_t, b : *bson_t, key : *char) : bool;

    // --- Mongoc ---

    @extern
    func mongoc_init() : void;

    @extern
    func mongoc_cleanup() : void;

    @extern
    func mongoc_client_new(uri_string : *char) : *mut mongoc_client_t;

    @extern
    func mongoc_client_destroy(client : *mut mongoc_client_t) : void;

    @extern
    func mongoc_client_new_from_uri(uri : *mongoc_uri_t) : *mut mongoc_client_t;

    @extern
    func mongoc_client_new_from_uri_with_error(uri : *mongoc_uri_t, error : *mut bson_error_t) : *mut mongoc_client_t;

    @extern
    func mongoc_client_get_database(client : *mut mongoc_client_t, name : *char) : *mut mongoc_database_t;

    @extern
    func mongoc_client_get_collection(client : *mut mongoc_client_t, db : *char, collection : *char) : *mut mongoc_collection_t;

    @extern
    func mongoc_client_command_simple(client : *mut mongoc_client_t, db_name : *char, command : *bson_t, read_prefs : *mongoc_read_prefs_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_client_get_database_names_with_opts(client : *mut mongoc_client_t, opts : *bson_t, error : *mut bson_error_t) : **char;

    @extern
    func mongoc_client_watch(client : *mut mongoc_client_t, pipeline : *bson_t, opts : *bson_t) : *mut mongoc_change_stream_t;

    @extern
    func mongoc_database_destroy(database : *mut mongoc_database_t) : void;

    @extern
    func mongoc_database_get_collection(database : *mut mongoc_database_t, name : *char) : *mut mongoc_collection_t;

    @extern
    func mongoc_database_drop(database : *mut mongoc_database_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_database_drop_with_opts(database : *mut mongoc_database_t, opts : *bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_database_command_simple(database : *mut mongoc_database_t, command : *bson_t, read_prefs : *mongoc_read_prefs_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_database_has_collection(database : *mut mongoc_database_t, name : *char, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_database_create_collection(database : *mut mongoc_database_t, name : *char, opts : *bson_t, error : *mut bson_error_t) : *mut mongoc_collection_t;

    @extern
    func mongoc_database_get_collection_names_with_opts(database : *mut mongoc_database_t, opts : *bson_t, error : *mut bson_error_t) : **char;

    @extern
    func mongoc_database_watch(database : *mut mongoc_database_t, pipeline : *bson_t, opts : *bson_t) : *mut mongoc_change_stream_t;

    @extern
    func mongoc_collection_destroy(collection : *mut mongoc_collection_t) : void;

    @extern
    func mongoc_collection_insert_one(collection : *mut mongoc_collection_t, document : *bson_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_insert_many(collection : *mut mongoc_collection_t, documents : **bson_t, n_documents : size_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_update_one(collection : *mut mongoc_collection_t, selector : *bson_t, update : *bson_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_update_many(collection : *mut mongoc_collection_t, selector : *bson_t, update : *bson_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_replace_one(collection : *mut mongoc_collection_t, selector : *bson_t, replacement : *bson_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_delete_one(collection : *mut mongoc_collection_t, selector : *bson_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_delete_many(collection : *mut mongoc_collection_t, selector : *bson_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_find_with_opts(collection : *mut mongoc_collection_t, filter : *bson_t, opts : *bson_t, read_prefs : *mongoc_read_prefs_t) : *mut mongoc_cursor_t;

    @extern
    func mongoc_collection_count_documents(coll : *mut mongoc_collection_t, filter : *bson_t, opts : *bson_t, read_prefs : *mongoc_read_prefs_t, reply : *mut bson_t, error : *mut bson_error_t) : i64;

    @extern
    func mongoc_collection_estimated_document_count(coll : *mut mongoc_collection_t, opts : *bson_t, read_prefs : *mongoc_read_prefs_t, reply : *mut bson_t, error : *mut bson_error_t) : i64;

    @extern
    func mongoc_collection_aggregate(collection : *mut mongoc_collection_t, flags : u32, pipeline : *bson_t, opts : *bson_t, read_prefs : *mongoc_read_prefs_t) : *mut mongoc_cursor_t;

    @extern
    func mongoc_collection_drop(collection : *mut mongoc_collection_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_drop_with_opts(collection : *mut mongoc_collection_t, opts : *bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_rename(collection : *mut mongoc_collection_t, new_db : *char, new_name : *char, drop_target : bool, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_create_indexes_with_opts(collection : *mut mongoc_collection_t, models : **mongoc_index_model_t, n_models : size_t, opts : *bson_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_drop_index(collection : *mut mongoc_collection_t, index_name : *char, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_find_indexes_with_opts(collection : *mut mongoc_collection_t, opts : *bson_t) : *mut mongoc_cursor_t;

    @extern
    func mongoc_collection_find_and_modify_with_opts(collection : *mut mongoc_collection_t, query : *bson_t, opts : *mongoc_find_and_modify_opts_t, reply : *mut bson_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_collection_watch(collection : *mut mongoc_collection_t, pipeline : *bson_t, opts : *bson_t) : *mut mongoc_change_stream_t;

    @extern
    func mongoc_cursor_next(cursor : *mut mongoc_cursor_t, bson : **bson_t) : bool;

    @extern
    func mongoc_cursor_error(cursor : *mut mongoc_cursor_t, error : *mut bson_error_t) : bool;

    @extern
    func mongoc_cursor_destroy(cursor : *mut mongoc_cursor_t) : void;

    @extern
    func mongoc_uri_new(uri_string : *char) : *mut mongoc_uri_t;

    @extern
    func mongoc_uri_new_with_error(uri_string : *char, error : *mut bson_error_t) : *mut mongoc_uri_t;

    @extern
    func mongoc_uri_destroy(uri : *mut mongoc_uri_t) : void;

    @extern
    func mongoc_client_pool_new(uri : *mongoc_uri_t) : *mut mongoc_client_pool_t;

    @extern
    func mongoc_client_pool_destroy(pool : *mut mongoc_client_pool_t) : void;

    @extern
    func mongoc_client_pool_pop(pool : *mut mongoc_client_pool_t) : *mut mongoc_client_t;

    @extern
    func mongoc_client_pool_push(pool : *mut mongoc_client_pool_t, client : *mut mongoc_client_t) : void;

    @extern
    func mongoc_client_pool_try_pop(pool : *mut mongoc_client_pool_t) : *mut mongoc_client_t;

    @extern
    func mongoc_client_pool_set_appname(pool : *mut mongoc_client_pool_t, appname : *char) : bool;

    @extern
    func mongoc_read_prefs_new(mode : int) : *mut mongoc_read_prefs_t;

    @extern
    func mongoc_read_prefs_destroy(read_prefs : *mut mongoc_read_prefs_t) : void;

    @extern
    func mongoc_read_concern_new() : *mut mongoc_read_concern_t;

    @extern
    func mongoc_read_concern_destroy(read_concern : *mut mongoc_read_concern_t) : void;

    @extern
    func mongoc_read_concern_set_level(read_concern : *mut mongoc_read_concern_t, level : *char) : bool;

    @extern
    func mongoc_write_concern_new() : *mut mongoc_write_concern_t;

    @extern
    func mongoc_write_concern_destroy(write_concern : *mut mongoc_write_concern_t) : void;

    @extern
    func mongoc_write_concern_set_w(write_concern : *mut mongoc_write_concern_t, w : i32) : void;

    @extern
    func mongoc_index_model_new(keys : *bson_t, opts : *bson_t) : *mut mongoc_index_model_t;

    @extern
    func mongoc_index_model_destroy(model : *mut mongoc_index_model_t) : void;

    @extern
    func mongoc_change_stream_next(stream : *mut mongoc_change_stream_t, bson : **bson_t) : bool;

    @extern
    func mongoc_change_stream_error_document(stream : *mongoc_change_stream_t, error : *mut bson_error_t, doc : *mut *bson_t) : bool;

    @extern
    func mongoc_change_stream_destroy(stream : *mut mongoc_change_stream_t) : void;

    // --- find_and_modify ---

    @extern
    func mongoc_find_and_modify_opts_new() : *mut mongoc_find_and_modify_opts_t;

    @extern
    func mongoc_find_and_modify_opts_destroy(opts : *mut mongoc_find_and_modify_opts_t) : void;

    @extern
    func mongoc_find_and_modify_opts_set_sort(opts : *mut mongoc_find_and_modify_opts_t, sort : *bson_t) : bool;

    @extern
    func mongoc_find_and_modify_opts_set_update(opts : *mut mongoc_find_and_modify_opts_t, update : *bson_t) : bool;

    @extern
    func mongoc_find_and_modify_opts_set_fields(opts : *mut mongoc_find_and_modify_opts_t, fields : *bson_t) : bool;

    @extern
    func mongoc_find_and_modify_opts_set_flags(opts : *mut mongoc_find_and_modify_opts_t, flags : u32) : bool;

    @extern
    func mongoc_find_and_modify_opts_set_bypass_document_validation(opts : *mut mongoc_find_and_modify_opts_t, bypass : bool) : bool;

    @extern
    func mongoc_find_and_modify_opts_append(opts : *mut mongoc_find_and_modify_opts_t, doc : *bson_t) : bool;

}

// Opaque types
public struct bson_t {
    var flags : u32;
    var len : u32;
    var padding : [112]u8;
}
public struct bson_oid_t {
    var bytes : [12]u8;
}
public struct bson_iter_t {
    var raw : *u8;
    var len : u32;
    var off : u32;
    var type_off : u32;
    var key_off : u32;
    var d1 : u32;
    var d2 : u32;
    var d3 : u32;
    var d4 : u32;
    var next_off : u32;
    var err_off : u32;
    var value : [256]u8; // Padding for internal value
}
public struct bson_error_t {
    var domain : u32;
    var code : u32;
    var message : [504]char;
}

public struct mongoc_client_t {}
public struct mongoc_client_pool_t {}
public struct mongoc_database_t {}
public struct mongoc_collection_t {}
public struct mongoc_cursor_t {}
public struct mongoc_uri_t {}
public struct mongoc_read_prefs_t {}
public struct mongoc_read_concern_t {}
public struct mongoc_write_concern_t {}
public struct mongoc_index_model_t {}
public struct mongoc_change_stream_t {}
public struct mongoc_find_and_modify_opts_t {}

}
