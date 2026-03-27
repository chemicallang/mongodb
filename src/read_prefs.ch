public namespace mongodb {

public enum ReadMode {
    Primary = 1,
    Secondary = 2,
    PrimaryPreferred = 3,
    SecondaryPreferred = 4,
    Nearest = 5
}

@never_destructed
public const EmptyReadPrefs = ReadPrefs { handle : null }

// TODO: use internal direct initialization
@direct_init
public struct ReadPrefs {
    internal var handle : *mut mongoc_read_prefs_t = null;

    @constructor
    func make(h : *mut mongoc_read_prefs_t) {
        return ReadPrefs { handle : h }
    }

    @constructor
    func new(mode : ReadMode) {
        return ReadPrefs.make(ffi::mongoc_read_prefs_new(mode as int))
    }

    @delete
    func delete(&mut self) {
        if(self.handle != null) {
            ffi::mongoc_read_prefs_destroy(self.handle);
            self.handle = null;
        }
    }
}

}
