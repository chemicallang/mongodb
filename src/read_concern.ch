public namespace mongodb {

public struct ReadConcern {
    internal var handle : *mut mongoc_read_concern_t = null;

    @constructor
    func make(h : *mut mongoc_read_concern_t) {
        return ReadConcern { handle : h }
    }

    @constructor
    func new() {
        return ReadConcern.make(ffi::mongoc_read_concern_new())
    }

    func is_null(&self) : bool {
        return handle == null
    }

    public func set_level(&self, level : std::string_view) : bool {
        return ffi::mongoc_read_concern_set_level(self.handle, level.data())
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_read_concern_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
