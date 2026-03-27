using std::Result;
using std::Option;

public namespace mongodb {

public struct Cursor {
    internal var handle : *mut mongoc_cursor_t = null;

    @constructor
    func make(h : *mut mongoc_cursor_t) {
        return Cursor { handle : h }
    }

    public func next(&mut self) : Result<Option<Document>, Error> {
        var doc_ptr : *bson_t = null;
        const res = ffi::mongoc_cursor_next(self.handle, &mut doc_ptr);
        if(!res) {
            var error : bson_error_t;
            if(ffi::mongoc_cursor_error(self.handle, &mut error)) {
                return Result.Err<Option<Document>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&error.message[0])))
            }
            return Result.Ok<Option<Document>, Error>(Option.None<Document>())
        }
        return Result.Ok<Option<Document>, Error>(Option.Some<Document>(Document.make(doc_ptr as *mut bson_t, false)))
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_cursor_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
