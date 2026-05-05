module mongodb_macos_arm64

link path "./"

link bson2
link mongoc2

ship "libbson2.dylib"
ship "libbson2.2.dylib"
ship "libbson2.2.2.3.dylib"
ship "libmongoc2.dylib"
ship "libmongoc2.2.dylib"
ship "libmongoc2.2.2.3.dylib"