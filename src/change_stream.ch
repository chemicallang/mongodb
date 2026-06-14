using std::Result;
using std::Option;

public namespace mongodb {

public struct ChangeStream {
    internal var handle : *mut mongoc_change_stream_t = null;

    @constructor
    func make(h : *mut mongoc_change_stream_t) {
        return ChangeStream { handle : h }
    }

    public func next(&self) : Result<std::Option<Document>, Error> {
        var doc_ptr : *bson_t = null;
        const res = ffi::mongoc_change_stream_next(self.handle, &raw mut doc_ptr);
        
        if(!res) {
            var error : bson_error_t;
            var err_doc : *bson_t = null;
            if(ffi::mongoc_change_stream_error_document(self.handle, &raw mut error, &raw mut err_doc)) {
                return Result.Err<std::Option<Document>, Error>(Error.Bson(error.domain, error.code, std::string.make_no_len(&raw error.message[0])))
            }
            return Result.Ok<std::Option<Document>, Error>(std::Option.None<Document>())
        }
        
        return Result.Ok<std::Option<Document>, Error>(std::Option.Some<Document>(Document.make(doc_ptr as *mut bson_t, false)))
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_change_stream_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
