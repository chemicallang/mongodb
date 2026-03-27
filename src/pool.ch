public namespace mongodb {

public struct ClientPool {
    internal var handle : *mut mongoc_client_pool_t = null;

    @constructor
    func make(h : *mut mongoc_client_pool_t) {
        return ClientPool { handle : h }
    }

    @constructor
    func new(uri : &Uri) {
        return ClientPool.make(ffi::mongoc_client_pool_new(uri.handle))
    }

    public func pop(&self) : Client {
        return Client.make(ffi::mongoc_client_pool_pop(self.handle))
    }

    public func push(&self, client : &mut Client) {
        ffi::mongoc_client_pool_push(self.handle, client.release_handle())
    }

    public func try_pop(&self) : std::Option<Client> {
        const h = ffi::mongoc_client_pool_try_pop(self.handle);
        if(h == null) return std::Option.None<Client>();
        return std::Option.Some<Client>(Client.make(h))
    }

    public func set_appname(&self, name : std::string_view) : bool {
        return ffi::mongoc_client_pool_set_appname(self.handle, name.data())
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_client_pool_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
