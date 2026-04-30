public namespace mongodb {

public struct Unit {}

public variant Error {
    Code(code : u32)
    Message(msg : std::string)
    Runtime(msg : *char)
    Bson(domain : u32, code : u32, message : std::string)

    func to_string(&self) : std::string {
        switch(self) {
            Code(code) => {
                var s = std::string("MongoDB Error Code: ")
                s.append_integer(code as bigint)
                return s
            }
            Message(msg) => {
                var s = std::string("MongoDB Error: ")
                s.append_view(msg.to_view())
                return s
            }
            Runtime(msg) => {
                var s = std::string("MongoDB Runtime Error: ")
                s.append_char_ptr(msg)
                return s
            }
            Bson(domain, code, message) => {
                var s = std::string("MongoDB BSON Error [")
                s.append_integer(domain as bigint)
                s.append_view(":")
                s.append_integer(code as bigint)
                s.append_view("]: ")
                s.append_view(message.to_view())
                return s
            }
        }
    }
}

}
