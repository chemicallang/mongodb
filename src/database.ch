using std::Result;

public namespace mongodb {

public struct Database {
    internal var handle : *mut mongoc_database_t = null;

    @constructor
    func make(h : *mut mongoc_database_t) {
        return Database { handle : h }
    }

    public func get_collection(&self, name : std::string_view) : Collection {
        if(self.handle == null) return Collection.make(null)
        return Collection.make(ffi::mongoc_database_get_collection(self.handle, name.data()))
    }

    public func drop(&mut self) : Result<Unit, Error> {
        if(self.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid database handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_database_drop(self.handle, &raw mut error);
        ffi::mongoc_database_destroy(self.handle);
        self.handle = null;
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func command_simple(&self, command : &Document, read_prefs : &ReadPrefs = &EmptyReadPrefs) : Result<Document, Error> {
        if(self.handle == null || command.handle == null) return Result.Err<Document, Error>(Error.Runtime("Invalid handle"))
        var reply : bson_t;
        var error : bson_error_t;
        const res = ffi::mongoc_database_command_simple(self.handle, command.handle, read_prefs.handle, &raw mut reply, &raw mut error);
        if(!res) {
            return Result.Err<Document, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Document, Error>(Document.make(ffi::bson_copy(&raw mut reply), true))
    }

    public func has_collection(&self, name : std::string_view) : Result<bool, Error> {
        if(self.handle == null) return Result.Err<bool, Error>(Error.Runtime("Invalid database handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_database_has_collection(self.handle, name.data(), &raw mut error);
        // has_collection returns false and error.code=0 if not found, or false and error.code!=0 on error      
        if(!res && error.code != 0) {
            return Result.Err<bool, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<bool, Error>(res)
    }

    public func create_collection(&self, name : std::string_view, opts : &Document = &EmptyOpts) : Result<Collection, Error> {
        if(self.handle == null) return Result.Err<Collection, Error>(Error.Runtime("Invalid database handle"))
        var error : bson_error_t;
        const coll_handle = ffi::mongoc_database_create_collection(self.handle, name.data(), opts.handle, &raw mut error);
        if(coll_handle == null) {
            return Result.Err<Collection, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Collection, Error>(Collection.make(coll_handle))
    }

    public func get_collection_names(&self, opts : &Document = &EmptyOpts) : Result<std::vector<std::string>, Error> {
        if(self.handle == null) return Result.Err<std::vector<std::string>, Error>(Error.Runtime("Invalid database handle"))
        var error : bson_error_t;
        const strv = ffi::mongoc_database_get_collection_names_with_opts(self.handle, opts.handle, &raw mut error);
        if(strv == null) {
            return Result.Err<std::vector<std::string>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
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

    public func drop_collection(&self, name : std::string_view) : Result<Unit, Error> {
        if(self.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid database handle"))
        var coll = self.get_collection(name);
        return coll.drop()
    }

    public func watch(&self, pipeline : &Document, opts : &Document = &EmptyOpts) : ChangeStream {
        if(self.handle == null || pipeline.handle == null) return ChangeStream.make(null)
        return ChangeStream.make(ffi::mongoc_database_watch(self.handle, pipeline.handle, opts.handle))
    }

    public func is_null(&self) : bool {
        return self.handle == null
    }

    public func is_valid(&self) : bool {
        return self.handle != null
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
