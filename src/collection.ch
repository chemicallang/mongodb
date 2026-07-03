using std::Result;
using std::Option;

public namespace mongodb {

public enum FindAndModifyFlags : u32 {
    None = 0,
    Remove = 1,
    ReturnNew = 2,
    Upsert = 4,
}

public enum FindAndModifyReturn {
    Before,
    After
}

public struct FindAndModifyOpts {
    internal var handle : *mut mongoc_find_and_modify_opts_t = null;

    @constructor
    func new() {
        return FindAndModifyOpts { handle : ffi::mongoc_find_and_modify_opts_new() }
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_find_and_modify_opts_destroy(self.handle);
            self.handle = null;
        }
    }

    public func set_sort(&self, sort : &Document) : bool {
        if(self.handle == null || sort.handle == null) return false;
        return ffi::mongoc_find_and_modify_opts_set_sort(self.handle, sort.handle)
    }

    public func set_update(&self, update : &Document) : bool {
        if(self.handle == null || update.handle == null) return false;
        return ffi::mongoc_find_and_modify_opts_set_update(self.handle, update.handle)
    }

    public func set_fields(&self, fields : &Document) : bool {
        if(self.handle == null || fields.handle == null) return false;
        return ffi::mongoc_find_and_modify_opts_set_fields(self.handle, fields.handle)
    }

    public func set_flags(&self, flags : FindAndModifyFlags) : bool {
        if(self.handle == null) return false;
        return ffi::mongoc_find_and_modify_opts_set_flags(self.handle, flags as u32)
    }

    public func set_bypass_document_validation(&self, bypass : bool) : bool {
        if(self.handle == null) return false;
        return ffi::mongoc_find_and_modify_opts_set_bypass_document_validation(self.handle, bypass)
    }

    public func append(&self, doc : &Document) : bool {
        if(self.handle == null || doc.handle == null) return false;
        return ffi::mongoc_find_and_modify_opts_append(self.handle, doc.handle)
    }
}

public struct WriteResult {
    public var matched_count : i64 = 0;
    public var modified_count : i64 = 0;
    public var upserted_count : i64 = 0;

    @constructor
    func make(matched : i64, modified : i64, upserted : i64) {
        return WriteResult { matched_count : matched, modified_count : modified, upserted_count : upserted }
    }
}

internal func extract_fam_value(reply : *mut bson_t) : Option<Document> {
    var it : bson_iter_t;
    if(!ffi::bson_iter_init_find(&raw mut it, reply, "value")) {
        return Option.None<Document>()
    }
    var len : u32 = 0;
    var data : *u8 = null;
    ffi::bson_iter_document(&raw mut it, &raw mut len, &raw mut data);
    if(data == null) return Option.None<Document>();
    return Option.Some<Document>(Document.make(ffi::bson_new_from_data(data, len as size_t), true))
}

internal func reply_as_write_result(reply : *mut bson_t) : WriteResult {
    var it : bson_iter_t;
    ffi::bson_iter_init(&raw mut it, reply);
    var matched = 0i64;
    var modified = 0i64;
    var upserted = 0i64;
    while(ffi::bson_iter_next(&raw mut it)) {
        const key = std::string_view(ffi::bson_iter_key(&raw it));
        if(key.equals("matchedCount") || key.equals("n")) {
            matched = ffi::bson_iter_int32(&raw it) as i64;
        } else if(key.equals("modifiedCount") || key.equals("nModified")) {
            modified = ffi::bson_iter_int32(&raw it) as i64;
        } else if(key.equals("upsertedCount")) {
            upserted = ffi::bson_iter_int32(&raw it) as i64;
        }
    }
    return WriteResult.make(matched, modified, upserted);
}

public struct Collection {
    internal var handle : *mut mongoc_collection_t = null;

    @constructor
    func make(h : *mut mongoc_collection_t) {
        return Collection { handle : h }
    }

    public func insert_one(&self, doc : &Document, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null || doc.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid collection or document handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_insert_one(self.handle, doc.handle, opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func insert_one_with_id(&self, doc : &Document, opts : &Document = &EmptyOpts) : Result<OID, Error> {
        if(self.handle == null || doc.handle == null) return Result.Err<OID, Error>(Error.Runtime("Invalid collection or document handle"))
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
            doc.append_oid("_id", &oid)
        }

        const res = ffi::mongoc_collection_insert_one(self.handle, doc.handle, opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<OID, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<OID, Error>(oid)
    }

    public func insert_many(&self, docs : &std::span<Document>, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid collection handle"))
        var error : bson_error_t;
        var handles = std::vector<*mut bson_t>();
        handles.reserve(docs.size())
        for(var i : size_t = 0; i < docs.size(); i = i + 1) {
            var h = docs.get(i).handle;
            if(h == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid document handle in insert_many"))
            handles.push_back(h);
        }

        const res = ffi::mongoc_collection_insert_many(self.handle, handles.data() as **bson_t, docs.size(), opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func create_index(&self, keys : &Document, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null || keys.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid collection or keys handle"))
        var error : bson_error_t;
        var model = ffi::mongoc_index_model_new(keys.handle, opts.handle);
        const res = ffi::mongoc_collection_create_indexes_with_opts(self.handle, &raw mut model, 1, null, null, &raw mut error);
        ffi::mongoc_index_model_destroy(model);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }


    public func update_one(&self, selector : &Document, update : &Document, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null || selector.handle == null || update.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_update_one(self.handle, selector.handle, update.handle, opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func update_one_with_result(&self, selector : &Document, update : &Document, opts : &Document = &EmptyOpts) : Result<WriteResult, Error> {
        var error : bson_error_t;
        var reply : bson_t;
        const res = ffi::mongoc_collection_update_one(self.handle, selector.handle, update.handle, opts.handle, &raw mut reply, &raw mut error);
        if(!res) {
            ffi::bson_destroy(&raw mut reply);
            return Result.Err<WriteResult, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        const wr = reply_as_write_result(&raw mut reply);
        ffi::bson_destroy(&raw mut reply);
        return Result.Ok<WriteResult, Error>(wr)
    }

    public func delete_one(&self, selector : &Document, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null || selector.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_delete_one(self.handle, selector.handle, opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func delete_many(&self, selector : &Document, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null || selector.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_delete_many(self.handle, selector.handle, opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func update_many(&self, selector : &Document, update : &Document, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null || selector.handle == null || update.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_update_many(self.handle, selector.handle, update.handle, opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func replace_one(&self, selector : &Document, replacement : &Document, opts : &Document = &EmptyOpts) : Result<Unit, Error> {
        if(self.handle == null || selector.handle == null || replacement.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_replace_one(self.handle, selector.handle, replacement.handle, opts.handle, null, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func find(&self, filter : &Document, opts : &Document = &EmptyOpts) : Cursor {
        if(self.handle == null || filter.handle == null) return Cursor.make(null)
        return Cursor.make(ffi::mongoc_collection_find_with_opts(self.handle, filter.handle, opts.handle, null))
    }

    public func rename(&self, new_db : std::string_view, new_name : std::string_view, drop_target : bool = false) : Result<Unit, Error> {
        if(self.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid collection handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_rename(self.handle, new_db.data(), new_name.data(), drop_target, &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func drop_index(&self, name : std::string_view) : Result<Unit, Error> {
        if(self.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid collection handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_drop_index(self.handle, name.data(), &raw mut error);
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func watch(&self, pipeline : &Document, opts : &Document = &EmptyOpts) : ChangeStream {
        if(self.handle == null || pipeline.handle == null) return ChangeStream.make(null)
        return ChangeStream.make(ffi::mongoc_collection_watch(self.handle, pipeline.handle, opts.handle))       
    }


    public func count_documents(&self, filter : &Document, opts : &Document = &EmptyOpts, read_prefs : &ReadPrefs = &EmptyReadPrefs) : Result<i64, Error> {
        if(self.handle == null || filter.handle == null) return Result.Err<i64, Error>(Error.Runtime("Invalid handle"))
        var error : bson_error_t;
        const count = ffi::mongoc_collection_count_documents(self.handle, filter.handle, opts.handle, read_prefs.handle, null, &raw mut error);
        if(count < 0) {
            return Result.Err<i64, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<i64, Error>(count)
    }

    public func estimated_document_count(&self, opts : &Document = &EmptyOpts, read_prefs : &ReadPrefs = &EmptyReadPrefs) : Result<i64, Error> {
        if(self.handle == null) return Result.Err<i64, Error>(Error.Runtime("Invalid collection handle"))
        var error : bson_error_t;
        const count = ffi::mongoc_collection_estimated_document_count(self.handle, opts.handle, read_prefs.handle, null, &raw mut error);
        if(count < 0) {
            return Result.Err<i64, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<i64, Error>(count)
    }

    public func drop(&mut self) : Result<Unit, Error> {
        if(self.handle == null) return Result.Err<Unit, Error>(Error.Runtime("Invalid collection handle"))
        var error : bson_error_t;
        const res = ffi::mongoc_collection_drop(self.handle, &raw mut error);
        ffi::mongoc_collection_destroy(self.handle);
        self.handle = null;
        if(!res) {
            return Result.Err<Unit, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        return Result.Ok<Unit, Error>(Unit{})
    }

    public func aggregate(&self, pipeline : &Document, opts : &Document = &EmptyOpts, read_prefs : &ReadPrefs = &EmptyReadPrefs) : Cursor {
        if(self.handle == null || pipeline.handle == null) return Cursor.make(null)
        return Cursor.make(ffi::mongoc_collection_aggregate(self.handle, 0, pipeline.handle, opts.handle, read_prefs.handle))
    }

    public func find_one_and_update(&self, filter : &Document, update : &Document, return_doc : FindAndModifyReturn = FindAndModifyReturn.After, sort : &Document = &EmptyOpts) : Result<Option<Document>, Error> {
        if(self.handle == null || filter.handle == null || update.handle == null) return Result.Err<Option<Document>, Error>(Error.Runtime("Invalid handle"))
        var opts = FindAndModifyOpts.new();
        opts.set_update(update);
        if(sort.is_valid()) { opts.set_sort(sort); }
        opts.set_flags(if(return_doc == FindAndModifyReturn.After) FindAndModifyFlags.ReturnNew else FindAndModifyFlags.None);
        var reply : bson_t;
        var error : bson_error_t;
        const res = ffi::mongoc_collection_find_and_modify_with_opts(self.handle, filter.handle, opts.handle, &raw mut reply, &raw mut error);
        if(!res) {
            return Result.Err<Option<Document>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        var result = extract_fam_value(&raw mut reply);
        ffi::bson_destroy(&raw mut reply);
        return Result.Ok<Option<Document>, Error>(result)
    }

    public func find_one_and_delete(&self, filter : &Document, sort : &Document = &EmptyOpts) : Result<Option<Document>, Error> {
        if(self.handle == null || filter.handle == null) return Result.Err<Option<Document>, Error>(Error.Runtime("Invalid handle"))
        var opts = FindAndModifyOpts.new();
        opts.set_flags(FindAndModifyFlags.Remove);
        if(sort.is_valid()) { opts.set_sort(sort); }
        var reply : bson_t;
        var error : bson_error_t;
        const res = ffi::mongoc_collection_find_and_modify_with_opts(self.handle, filter.handle, opts.handle, &raw mut reply, &raw mut error);
        if(!res) {
            return Result.Err<Option<Document>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        var result = extract_fam_value(&raw mut reply);
        ffi::bson_destroy(&raw mut reply);
        return Result.Ok<Option<Document>, Error>(result)
    }

    public func find_one_and_replace(&self, filter : &Document, replacement : &Document, return_doc : FindAndModifyReturn = FindAndModifyReturn.After, sort : &Document = &EmptyOpts) : Result<Option<Document>, Error> {
        if(self.handle == null || filter.handle == null || replacement.handle == null) return Result.Err<Option<Document>, Error>(Error.Runtime("Invalid handle"))
        var opts = FindAndModifyOpts.new();
        opts.set_update(replacement);
        if(sort.is_valid()) { opts.set_sort(sort); }
        opts.set_flags(if(return_doc == FindAndModifyReturn.After) FindAndModifyFlags.ReturnNew else FindAndModifyFlags.None);
        var reply : bson_t;
        var error : bson_error_t;
        const res = ffi::mongoc_collection_find_and_modify_with_opts(self.handle, filter.handle, opts.handle, &raw mut reply, &raw mut error);
        if(!res) {
            return Result.Err<Option<Document>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
        }
        var result = extract_fam_value(&raw mut reply);
        ffi::bson_destroy(&raw mut reply);
        return Result.Ok<Option<Document>, Error>(result)
    }

    public func find_indexes(&self, opts : &Document = &EmptyOpts) : Cursor {
        if(self.handle == null) return Cursor.make(null)
        return Cursor.make(ffi::mongoc_collection_find_indexes_with_opts(self.handle, opts.handle))
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
            ffi::mongoc_collection_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
