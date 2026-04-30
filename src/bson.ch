using std::Result;

public namespace mongodb {

@never_destructed
public const EmptyOpts = mongodb::Document { handle : null, is_owned = false }

// TODO: only allow initialization in current module using internal_direct_init
@direct_init
public struct Document {
    internal var handle : *mut bson_t = null;
    internal var is_owned : bool = true;

    @constructor
    func make(h : *mut bson_t, owned : bool = true) {
        return Document { handle : h, is_owned : owned }
    }

    @constructor
    func new() {
        return Document.make(ffi::bson_new(), true)
    }

    public func append_utf8(&self, key : std::string_view, value : std::string_view) : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_utf8(self.handle, key.data(), key.size() as int, value.data(), value.size() as int)
    }

    public func append_int32(&self, key : std::string_view, value : i32) : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_int32(self.handle, key.data(), key.size() as int, value)
    }

    public func append_int64(&self, key : std::string_view, value : i64) : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_int64(self.handle, key.data(), key.size() as int, value)
    }

    public func append_bool(&self, key : std::string_view, value : bool) : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_bool(self.handle, key.data(), key.size() as int, value)
    }

    public func append_double(&self, key : std::string_view, value : double) : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_double(self.handle, key.data(), key.size() as int, value)
    }

    public func append_null(&self, key : std::string_view) : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_null(self.handle, key.data(), key.size() as int)
    }

    public func append_regex(&self, key : std::string_view, regex : std::string_view, options : std::string_view = "") : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_regex(self.handle, key.data(), key.size() as int, regex.data(), options.data()) 
    }

    public func append_timestamp(&self, key : std::string_view, timestamp : u32, increment : u32) : bool {      
        if(self.handle == null) return false;
        return ffi::bson_append_timestamp(self.handle, key.data(), key.size() as int, timestamp, increment)     
    }

    public func append_oid(&self, key : std::string_view, oid : &OID) : bool {
        if(self.handle == null) return false;
        return ffi::bson_append_oid(self.handle, key.data(), key.size() as int, &oid.handle)
    }

    public func append_document(&self, key : std::string_view, doc : &Document) : bool {
        if(self.handle == null || doc.handle == null) return false;
        return ffi::bson_append_document(self.handle, key.data(), key.size() as int, doc.handle)
    }

    public func append_array(&self, key : std::string_view, doc : &Document) : bool {
        if(self.handle == null || doc.handle == null) return false;
        return ffi::bson_append_array(self.handle, key.data(), key.size() as int, doc.handle)
    }

    public func as_json(&self) : std::string {
        if(self.handle == null) return std::string();
        var len : size_t = 0;
        const ptr = ffi::bson_as_relaxed_extended_json(self.handle, &mut len);
        if(ptr == null) return std::string();
        var s = std::string.constructor(ptr, len);
        ffi::bson_free(ptr as *mut void);
        return s;
    }

    public func as_canonical_json(&self) : std::string {
        if(self.handle == null) return std::string();
        var len : size_t = 0;
        const ptr = ffi::bson_as_canonical_extended_json(self.handle, &mut len);
        if(ptr == null) return std::string();
        var s = std::string.constructor(ptr, len);
        ffi::bson_free(ptr as *mut void);
        return s;
    }

    public func is_null(&self) : bool {
        return self.handle == null
    }

    public func is_valid(&self) : bool {
        return self.handle != null
    }

    public func iter(&self) : Iter {
        var it : bson_iter_t;
        var valid = false;
        if(self.handle != null) {
            valid = ffi::bson_iter_init(&mut it, self.handle);
        }
        return Iter.make(it, valid)
    }

    @delete
    func delete(&mut self) {
        if(self.is_owned && self.handle != null) {
            ffi::bson_destroy(self.handle);
            self.handle = null;
        }
    }
}

public struct OID {
    internal var handle : bson_oid_t;

    @constructor
    func new() {
        var o : OID;
        ffi::bson_oid_init(&mut o.handle, null);
        return o;
    }

    @constructor
    func from_string(s : std::string_view) {
        var o : OID;
        ffi::bson_oid_init_from_string(&mut o.handle, s.data());
        return o;
    }

    public func to_string(&self) : std::string {
        var buf : [25]char;
        ffi::bson_oid_to_string(&self.handle, &mut buf[0]);
        return std::string.make_no_len(&buf[0])
    }

    public func is_null(&self) : bool {
        for(var i=0u; i<12u; i++) {
            if(self.handle.bytes[i] != 0u8) return false
        }
        return true
    }
}

public struct Iter {
    internal var handle : bson_iter_t;
    internal var valid : bool = false;

    @constructor
    func make(h : bson_iter_t, v : bool) {
        return Iter { handle : h, valid : v }
    }

    public func next(&mut self) : bool {
        if(!self.valid) return false;
        return ffi::bson_iter_next(&mut self.handle)
    }

    public func key(&self) : std::string_view {
        if(!self.valid) return std::string_view("");
        return std::string_view(ffi::bson_iter_key(&self.handle))
    }

    public func type(&self) : u32 {
        if(!self.valid) return 0;
        return ffi::bson_iter_type(&self.handle) as u32
    }

    public func int32(&self) : i32 {
        if(!self.valid) return 0;
        return ffi::bson_iter_int32(&self.handle)
    }

    public func int64(&self) : i64 {
        if(!self.valid) return 0;
        return ffi::bson_iter_int64(&self.handle)
    }

    public func double(&self) : double {
        if(!self.valid) return 0.0;
        return ffi::bson_iter_double(&self.handle)
    }

    public func bool(&self) : bool {
        if(!self.valid) return false;
        return ffi::bson_iter_bool(&self.handle)
    }

    public func utf8(&self) : std::string_view {
        if(!self.valid) return std::string_view("");
        var len : u32 = 0;
        const ptr = ffi::bson_iter_utf8(&self.handle, &mut len);
        return std::string_view(ptr, len as size_t)
    }

    public func oid(&self) : OID {
        var o : OID;
        if(!self.valid) return o;
        const ptr = ffi::bson_iter_oid(&self.handle);
        if(ptr != null) {
            o.handle = *ptr;
        }
        return o;
    }

    public func document(&self) : Document {
        if(!self.valid) return Document { handle : null, is_owned : false };
        var len : u32 = 0;
        var data : *u8 = null;
        ffi::bson_iter_document(&self.handle, &mut len, &mut data);
        if(data == null) return Document { handle : null, is_owned : false };
        return Document.make(ffi::bson_new_from_data(data, len as size_t), true)
    }

    public func array(&self) : Document {
        if(!self.valid) return Document { handle : null, is_owned : false };
        var len : u32 = 0;
        var data : *u8 = null;
        ffi::bson_iter_array(&self.handle, &mut len, &mut data);
        if(data == null) return Document { handle : null, is_owned : false };
        return Document.make(ffi::bson_new_from_data(data, len as size_t), true)
    }
}

}
