module mongodb_macos_arm64

link path "./"

link bson2
link mongoc2

ship "libbson2.dylib"
ship "libmongoc2.dylib"
