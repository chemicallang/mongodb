using std::Result;

public namespace mongodb {

public struct Client {
    internal var handle : *mut mongoc_client_t = null;

    @constructor
    func make(h : *mut mongoc_client_t) {
        return Client { handle : h }
    }

    public func get_database(&self, name : std::string_view) : Database {
        if(self.handle == null) return Database.make(null)
        return Database.make(ffi::mongoc_client_get_database(self.handle, name.data()))
    }

    public func get_collection(&self, db : std::string_view, collection : std::string_view) : Collection {      
        if(self.handle == null) return Collection.make(null)
        return Collection.make(ffi::mongoc_client_get_collection(self.handle, db.data(), collection.data()))    
    }

    public func command_simple(&self, db_name : std::string_view, command : &Document, read_prefs : &ReadPrefs = &EmptyReadPrefs) : Result<Document, Error> {
        if(self.handle == null || command.handle == null) return Result.Err<Document, Error>(Error.Runtime("Invalid handle"))
        var reply : bson_t;
        var error : bson_error_t;
        const res = ffi::mongoc_client_command_simple(self.handle, db_name.data(), command.handle, read_prefs.handle, &raw mut reply, &raw mut error);
        if(!res) {
            return Result.Err<Document, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Document, Error>(Document.make(&raw mut reply, true))
    }

    public func get_database_names(&self, opts : &Document = &EmptyOpts) : Result<std::vector<std::string>, Error> {
        if(self.handle == null) return Result.Err<std::vector<std::string>, Error>(Error.Runtime("Invalid client handle"))
        var error : bson_error_t;
        const strv = ffi::mongoc_client_get_database_names_with_opts(self.handle, opts.handle, &raw mut error);
        if(strv == null) {
            return Result.Err<std::vector<std::string>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }

        var vec = std::vector<std::string>();
        // Manual pointer iteration for char**
        var curr = strv;
        while(*curr != null) {
            vec.push_back(std::string.make_no_len(*curr));
            curr = (curr as usize + 8) as **char; // assuming 64-bit pointers
        }
        ffi::bson_strfreev(strv);
        return Result.Ok<std::vector<std::string>, Error>(vec);
    }

    public func watch(&self, pipeline : &Document, opts : &Document = &EmptyOpts) : ChangeStream {
        if(self.handle == null || pipeline.handle == null) return ChangeStream.make(null)
        return ChangeStream.make(ffi::mongoc_client_watch(self.handle, pipeline.handle, opts.handle))
    }

    public func is_null(&self) : bool {
        return self.handle == null;
    }

    public func is_valid(&self) : bool {
        return self.handle != null;
    }
    internal func release_handle(&mut self) : *mut mongoc_client_t {
        const h = self.handle;
        self.handle = null;
        return h;
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_client_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
