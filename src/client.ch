using std::Result;

public namespace mongodb {

public struct Client {
    internal var handle : *mut mongoc_client_t = null;

    @constructor
    func make(h : *mut mongoc_client_t) {
        return Client { handle : h }
    }

    public func get_database(&self, name : std::string_view) : Database {
        return Database.make(ffi::mongoc_client_get_database(self.handle, name.data()))
    }

    public func get_collection(&self, db : std::string_view, collection : std::string_view) : Collection {
        return Collection.make(ffi::mongoc_client_get_collection(self.handle, db.data(), collection.data()))
    }

    public func command_simple(&self, db_name : std::string_view, command : &Document, read_prefs : &ReadPrefs = EmptyReadPrefs) : Result<Document, Error> {
        var reply : bson_t;
        var error : bson_error_t;
        const res = ffi::mongoc_client_command_simple(self.handle, db_name.data(), command.handle, read_prefs.handle, &mut reply, &mut error);
        if(!res) {
            return Result.Err<Document, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Document, Error>(Document.make(&mut reply, true))
    }

    public func get_database_names(&self, opts : &Document = EmptyOpts) : Result<std::vector<std::string>, Error> {
        var error : bson_error_t;
        const strv = ffi::mongoc_client_get_database_names_with_opts(self.handle, opts.handle, &mut error);
        if(strv == null) {
            return Result.Err<std::vector<std::string>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
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

    public func watch(&self, pipeline : &Document, opts : &Document = EmptyOpts) : ChangeStream {
        return ChangeStream.make(ffi::mongoc_client_watch(self.handle, pipeline.handle, opts.handle))
    }

    func isInvalid(&self) : bool {
        return handle == null;
    }

    func isValid(&self) : bool {
        return handle != null;
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
