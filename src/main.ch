public namespace mongodb {

public func init() {
    ffi::mongoc_init()
}

public func cleanup() {
    ffi::mongoc_cleanup()
}

public func get_version() : std::string_view {
    return std::string_view(ffi::mongoc_get_version())
}

}