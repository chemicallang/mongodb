module mongodb_linuxmusl_arm64

link path "./"

link bson2
link mongoc2

ship "libbson2.so"
ship "libbson2.so.2"
ship "libbson2.so.2.2.3"
ship "libmongoc2.so"
ship "libmongoc2.so.2"
ship "libmongoc2.so.2.2.3"