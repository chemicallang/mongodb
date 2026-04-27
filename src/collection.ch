using std::Result;

public namespace mongodb {

public struct Collection {
    internal var handle : *mut mongoc_collection_t = null;

    @constructor
    func make(h : *mut mongoc_collection_t) {
        return Collection { handle : h }
    }

    public func insert_one(&self, doc : &Document, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_insert_one(self.handle, doc.handle, opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func insert_one_with_id(&self, doc : &Document, opts : &Document = EmptyOpts) : Result<OID, Error> {
        var error : bson_error_t;

        // Ensure _id exists or create it
        var it = doc.iter()
        var has_id = false
        var oid = OID()
        while(it.next()) {
            if(it.key().equals("_id")) {
                has_id = true
                oid = it.oid()
                break
            }
        }

        if(!has_id) {
            oid = OID()
            doc.append_oid("_id", oid)
        }

        const res = ffi::mongoc_collection_insert_one(self.handle, doc.handle, opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<OID, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<OID, Error>(oid)
    }

    public func insert_many(&self, docs : &std::span<Document>, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        var handles = std::vector<*mut bson_t>();
        handles.reserve(docs.size())
        for(var i : size_t = 0; i < docs.size(); i = i + 1) {
            handles.push_back(docs.get(i).handle);
        }
        
        const res = ffi::mongoc_collection_insert_many(self.handle, handles.data() as **bson_t, docs.size(), opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func create_index(&self, keys : &Document, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        var model = ffi::mongoc_index_model_new(keys.handle, opts.handle);
        const res = ffi::mongoc_collection_create_indexes_with_opts(self.handle, &mut model, 1, null, null, &mut error);
        ffi::mongoc_index_model_destroy(model);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }


    public func update_one(&self, selector : &Document, update : &Document, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_update_one(self.handle, selector.handle, update.handle, opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func delete_one(&self, selector : &Document, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_delete_one(self.handle, selector.handle, opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func delete_many(&self, selector : &Document, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_delete_many(self.handle, selector.handle, opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func update_many(&self, selector : &Document, update : &Document, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_update_many(self.handle, selector.handle, update.handle, opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func replace_one(&self, selector : &Document, replacement : &Document, opts : &Document = EmptyOpts) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_replace_one(self.handle, selector.handle, replacement.handle, opts.handle, null, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func find(&self, filter : &Document, opts : &Document = EmptyOpts) : Cursor {
        return Cursor.make(ffi::mongoc_collection_find_with_opts(self.handle, filter.handle, opts.handle, null))
    }

    public func rename(&self, new_db : std::string_view, new_name : std::string_view, drop_target : bool = false) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_rename(self.handle, new_db.data(), new_name.data(), drop_target, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func drop_index(&self, name : std::string_view) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_drop_index(self.handle, name.data(), &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func watch(&self, pipeline : &Document, opts : &Document = EmptyOpts) : ChangeStream {
        return ChangeStream.make(ffi::mongoc_collection_watch(self.handle, pipeline.handle, opts.handle))
    }


    public func count_documents(&self, filter : &Document, opts : &Document = EmptyOpts, read_prefs : &ReadPrefs = EmptyReadPrefs) : Result<i64, Error> {
        var error : bson_error_t;
        const count = ffi::mongoc_collection_count_documents(self.handle, filter.handle, opts.handle, read_prefs.handle, null, &mut error);
        if(count < 0) {
            return Result.Err<i64, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<i64, Error>(count)
    }

    public func estimated_document_count(&self, opts : &Document = EmptyOpts, read_prefs : &ReadPrefs = EmptyReadPrefs) : Result<i64, Error> {
        var error : bson_error_t;
        const count = ffi::mongoc_collection_estimated_document_count(self.handle, opts.handle, read_prefs.handle, null, &mut error);
        if(count < 0) {
            return Result.Err<i64, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<i64, Error>(count)
    }

    public func drop(&self) : Result<Unit, Error> {
        var error : bson_error_t;
        const res = ffi::mongoc_collection_drop(self.handle, &mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func aggregate(&self, pipeline : &Document, opts : &Document = EmptyOpts, read_prefs : &ReadPrefs = EmptyReadPrefs) : Cursor {
        return Cursor.make(ffi::mongoc_collection_aggregate(self.handle, 0, pipeline.handle, opts.handle, read_prefs.handle))
    }


    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_collection_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
