using std::Result;

public namespace mongodb {

public struct Driver {

    @constructor
    func new() {
        ffi::mongoc_init();
        return Driver{}
    }

    func get_version(&self) : *char {
        return ffi::mongoc_get_version()
    }

    @delete
    func delete(&mut self) {
        ffi::mongoc_cleanup();
    }

    public func create_client(&self, uri_str : *char) : Result<Client, Error> {
        var error : bson_error_t;
        var uri_handle = ffi::mongoc_uri_new_with_error(uri_str, &raw mut error);
        if(uri_handle == null) {
            return Result.Err<Client, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        
        var client_handle = ffi::mongoc_client_new_from_uri_with_error(uri_handle, &raw mut error);
        ffi::mongoc_uri_destroy(uri_handle);
        
        if(client_handle == null) {
            return Result.Err<Client, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Client, Error>(Client.make(client_handle))
    }

    public func create_client_from_uri(&self, uri : &Uri) : Result<Client, Error> {
        var error : bson_error_t;
        var client_handle = ffi::mongoc_client_new_from_uri_with_error(uri.handle, &raw mut error);
        if(client_handle == null) {
            return Result.Err<Client, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Client, Error>(Client.make(client_handle))
    }
}


}