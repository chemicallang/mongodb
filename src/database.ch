using std::Result;

public namespace mongodb {

public struct Database {
    internal var handle : *mut mongoc_database_t = null;

    @constructor
    func make(h : *mut mongoc_database_t) {
        return Database { handle : h }
    }

    public func get_collection(&self, name : std::string_view) : Collection {
        return Collection.make(ffi::mongoc_database_get_collection(self.handle, name.data()))
    }

    public func drop(&self) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_database_drop(self.handle, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func command_simple(&self, command : &Document, read_prefs : &ReadPrefs = EmptyReadPrefs) : Result<Document, Error> {
        var reply : bson_t;
        var error : bson_error_t;
        const res = ffi::mongoc_database_command_simple(self.handle, command.handle, read_prefs.handle, &mut reply, &mut error);
        if(!res) {
            return Result.Err<Document, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Document, Error>(Document.make(&mut reply, true))
    }

    public func has_collection(&self, name : std::string_view) : Result<bool, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_database_has_collection(self.handle, name.data(), &mut error);
        // has_collection returns false and error.code=0 if not found, or false and error.code!=0 on error
        if(!res && error.code != 0) {
            return Result.Err<bool, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<bool, Error>(res)
    }

    public func create_collection(&self, name : std::string_view, opts : &Document = EmptyOpts) : Result<Collection, Error> {
        var error : bson_error_t;
        const coll_handle = ffi::mongoc_database_create_collection(self.handle, name.data(), opts.handle, &mut error);
        if(coll_handle == null) {
            return Result.Err<Collection, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Collection, Error>(Collection.make(coll_handle))
    }

    public func get_collection_names(&self, opts : &Document = EmptyOpts) : Result<std::vector<std::string>, Error> {
        var error : bson_error_t;
        const strv = ffi::mongoc_database_get_collection_names_with_opts(self.handle, opts.handle, &mut error);
        if(strv == null) {
            return Result.Err<std::vector<std::string>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        
        var vec = std::vector<std::string>();
        var curr = strv;
        while(*curr != null) {
            vec.push_back(std::string.make_no_len(*curr));
            curr = (curr as usize + 8) as **char;
        }
        ffi::bson_strfreev(strv);
        return Result.Ok<std::vector<std::string>, Error>(vec);
    }

    public func watch(&self, pipeline : &Document, opts : &Document = EmptyOpts) : ChangeStream {
        return ChangeStream.make(ffi::mongoc_database_watch(self.handle, pipeline.handle, opts.handle))
    }


    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_database_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
