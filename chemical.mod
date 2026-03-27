module mongodb_win_x64

link path "./"

link bson2
link mongoc2

ship "bson2.dll"
ship "mongoc2.dll"
ship "msvcp140.dll"
ship "vcruntime140.dll"