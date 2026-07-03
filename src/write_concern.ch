public namespace mongodb {

public struct WriteConcern {
    internal var handle : *mut mongoc_write_concern_t = null;

    @constructor
    func make(h : *mut mongoc_write_concern_t) {
        return WriteConcern { handle : h }
    }

    @constructor
    func new() {
        return WriteConcern.make(ffi::mongoc_write_concern_new())
    }

    func is_null(&self) : bool {
        return handle == null
    }

    public func set_w(&self, w : i32) {
        ffi::mongoc_write_concern_set_w(self.handle, w)
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_write_concern_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
