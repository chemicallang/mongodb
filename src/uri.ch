public namespace mongodb {

public struct Uri {
    internal var handle : *mut mongoc_uri_t = null;

    @constructor
    func make(h : *mut mongoc_uri_t) {
        return Uri { handle : h }
    }

    @constructor
    func new(uri_string : std::string_view) {
        return Uri.make(ffi::mongoc_uri_new(uri_string.data()))
    }

    func isValid(&self) : bool {
        return handle != null;
    }

    func isInvalid(&self) : bool {
        return handle == null;
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_uri_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
