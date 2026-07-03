using mongodb;
using std::Option;
using std::Result;

// ========== BSON Document Construction Tests ==========

@test
func test_document_create_empty(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(doc.is_null()) { env.error("Empty document should not be null"); return; }
    if(!doc.is_valid()) { env.error("New document should be valid"); return; }
    env.success("Empty document created")
}

@test
func test_document_append_utf8(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(!doc.append_utf8("name", "Alice")) { env.error("Failed to append utf8"); return; }
    if(!doc.append_utf8("greeting", "Hello, World!")) { env.error("Failed to append greeting"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with UTF-8 fields created")
}

@test
func test_document_append_numbers(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(!doc.append_int32("age", 25)) { env.error("Failed to append int32"); return; }
    if(!doc.append_int64("big", 10000000000i64)) { env.error("Failed to append int64"); return; }
    if(!doc.append_double("pi", 3.14159)) { env.error("Failed to append double"); return; }
    if(!doc.append_bool("active", true)) { env.error("Failed to append bool"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with number fields created")
}

@test
func test_document_append_null(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(!doc.append_null("empty")) { env.error("Failed to append null"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with null field created")
}

@test
func test_document_append_regex(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(!doc.append_regex("pattern", "^hello", "i")) { env.error("Failed to append regex"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with regex field created")
}

@test
func test_document_append_timestamp(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(!doc.append_timestamp("ts", 12345678u32, 0u32)) { env.error("Failed to append timestamp"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with timestamp field created")
}

@test
func test_document_append_oid(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var oid = mongodb::OID();
    if(!doc.append_oid("_id", &oid)) { env.error("Failed to append OID"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with OID field created")
}

@test
func test_document_append_subdocument(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var sub = mongodb::Document();
    sub.append_utf8("city", "New York");
    sub.append_int32("zip", 10001);
    if(!doc.append_document("address", &sub)) { env.error("Failed to append subdocument"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with subdocument created")
}

@test
func test_document_append_array(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var arr = mongodb::Document();
    arr.append_utf8("0", "apple");
    arr.append_utf8("1", "banana");
    arr.append_utf8("2", "cherry");
    if(!doc.append_array("items", &arr)) { env.error("Failed to append array"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON output should not be empty"); return; }
    env.success("Document with array field created")
}

@test
func test_document_append_chained(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(!doc.append_utf8("a", "1")) { env.error("Failed first append"); return; }
    if(!doc.append_int32("b", 2)) { env.error("Failed second append"); return; }
    if(!doc.append_bool("c", true)) { env.error("Failed third append"); return; }
    var json = doc.as_json();
    if(json.size() == 0) { env.error("JSON should not be empty"); return; }
    env.success("Chained appends work")
}

// ========== has_field / get_type Tests ==========

@test
func test_document_has_field(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_utf8("name", "Bob");
    doc.append_int32("age", 30);
    doc.append_bool("active", true);
    if(!doc.has_field("name")) { env.error("has_field('name') should be true"); return; }
    if(!doc.has_field("age")) { env.error("has_field('age') should be true"); return; }
    if(!doc.has_field("active")) { env.error("has_field('active') should be true"); return; }
    if(doc.has_field("nonexistent")) { env.error("has_field('nonexistent') should be false"); return; }
    env.success("has_field works correctly")
}

@test
func test_document_get_type(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_utf8("name", "Charlie");
    doc.append_int32("age", 35);
    doc.append_double("score", 92.5);
    doc.append_bool("pass", true);
    if(doc.get_type("name") != 2) { env.error("type of 'name' should be UTF8(2)"); return; }
    if(doc.get_type("age") != 16) { env.error("type of 'age' should be Int32(16)"); return; }
    if(doc.get_type("score") != 1) { env.error("type of 'score' should be Double(1)"); return; }
    if(doc.get_type("pass") != 8) { env.error("type of 'pass' should be Bool(8)"); return; }
    if(doc.get_type("missing") != 0) { env.error("type of missing field should be 0"); return; }
    env.success("get_type works correctly")
}

@test
func test_document_get_type_on_empty(env : &mut TestEnv) {
    var doc = mongodb::Document();
    if(doc.has_field("anything")) { env.error("Empty doc should not have fields"); return; }
    if(doc.get_type("anything") != 0) { env.error("Type of missing field should be 0"); return; }
    env.success("has_field/get_type on empty doc work")
}

// ========== JSON Roundtrip Tests ==========

@test
func test_document_json_roundtrip(env : &mut TestEnv) {
    var json_str = std::string_view("{\"name\":\"David\",\"age\":40,\"active\":true}");
    var res = mongodb::document_from_json(json_str);
    if(res is Result.Err) {
        env.error("Failed to parse JSON");
        return;
    }
    var Ok(doc) = res else unreachable;
    if(doc.is_null()) { env.error("Document from JSON should not be null"); return; }
    if(!doc.has_field("name")) { env.error("Should have 'name' field"); return; }
    if(!doc.has_field("age")) { env.error("Should have 'age' field"); return; }
    if(!doc.has_field("active")) { env.error("Should have 'active' field"); return; }
    env.success("JSON roundtrip successful")
}

@test
func test_document_json_roundtrip_complex(env : &mut TestEnv) {
    var json_str = std::string_view("{\"name\":\"Eve\",\"scores\":[95,87,92],\"address\":{\"city\":\"Boston\",\"state\":\"MA\"}}");
    var res = mongodb::document_from_json(json_str);
    if(res is Result.Err) {
        env.error("Failed to parse complex JSON");
        return;
    }
    var Ok(doc) = res else unreachable;
    if(doc.is_null()) { env.error("Document from JSON should not be null"); return; }
    if(!doc.has_field("name")) { env.error("Should have 'name' field"); return; }
    if(!doc.has_field("scores")) { env.error("Should have 'scores' field"); return; }
    if(!doc.has_field("address")) { env.error("Should have 'address' field"); return; }
    env.success("Complex JSON roundtrip successful")
}

@test
func test_document_json_invalid(env : &mut TestEnv) {
    var json_str = std::string_view("{invalid json}");
    var res = mongodb::document_from_json(json_str);
    if(res is Result.Ok) {
        env.error("Should have failed on invalid JSON");
        return;
    }
    env.success("Invalid JSON correctly rejected")
}

@test
func test_document_json_empty_string(env : &mut TestEnv) {
    var json_str = std::string_view("");
    var res = mongodb::document_from_json(json_str);
    if(res is Result.Ok) {
        env.error("Should have failed on empty JSON");
        return;
    }
    env.success("Empty JSON correctly rejected")
}

@test
func test_document_json_unicode(env : &mut TestEnv) {
    var json_str = std::string_view("{\"message\":\"Hello, 世界!\"}");
    var res = mongodb::document_from_json(json_str);
    if(res is Result.Err) {
        env.error("Failed to parse unicode JSON");
        return;
    }
    var Ok(doc) = res else unreachable;
    if(!doc.has_field("message")) { env.error("Should have 'message' field"); return; }
    env.success("Unicode JSON roundtrip works")
}

@test
func test_document_json_numbers(env : &mut TestEnv) {
    var json_str = std::string_view("{\"int\":42,\"float\":3.14,\"negative\":-10,\"big\":999999999999}");
    var res = mongodb::document_from_json(json_str);
    if(res is Result.Err) {
        env.error("Failed to parse numeric JSON");
        return;
    }
    var Ok(doc) = res else unreachable;
    if(!doc.has_field("int")) { env.error("Should have 'int' field"); return; }
    if(!doc.has_field("float")) { env.error("Should have 'float' field"); return; }
    if(!doc.has_field("negative")) { env.error("Should have 'negative' field"); return; }
    if(!doc.has_field("big")) { env.error("Should have 'big' field"); return; }
    env.success("JSON number parsing works")
}

@test
func test_document_json_boolean_and_null(env : &mut TestEnv) {
    var json_str = std::string_view("{\"t\":true,\"f\":false,\"n\":null}");
    var res = mongodb::document_from_json(json_str);
    if(res is Result.Err) {
        env.error("Failed to parse bool/null JSON");
        return;
    }
    var Ok(doc) = res else unreachable;
    if(!doc.has_field("t")) { env.error("Should have 't' field"); return; }
    if(!doc.has_field("f")) { env.error("Should have 'f' field"); return; }
    if(!doc.has_field("n")) { env.error("Should have 'n' field"); return; }
    env.success("JSON bool/null parsing works")
}

// ========== Document Copy Tests ==========

@test
func test_document_copy(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_utf8("name", "Frank");
    doc.append_int32("age", 28);
    var copy = doc.copy();
    if(copy.is_null()) { env.error("Copy should not be null"); return; }
    if(!copy.has_field("name")) { env.error("Copy should have 'name' field"); return; }
    if(!copy.has_field("age")) { env.error("Copy should have 'age' field"); return; }
    env.success("Document copy works correctly")
}

@test
func test_document_copy_independence(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_utf8("key", "original");
    var copy = doc.copy();
    doc.append_utf8("extra", "added later");
    if(!copy.has_field("key")) { env.error("Copy should have 'key' field"); return; }
    if(copy.has_field("extra")) { env.error("Copy should NOT have 'extra' field (independent copy)"); return; }
    env.success("Document copy is independent")
}

@test
func test_document_copy_empty(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var copy = doc.copy();
    if(copy.is_null()) { env.error("Copy of empty doc should not be null"); return; }
    env.success("Empty document copy works")
}

// ========== JSON Output Tests ==========

@test
func test_document_as_json(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_utf8("name", "Grace");
    doc.append_int32("age", 32);
    var relaxed = doc.as_json();
    var canonical = doc.as_canonical_json();
    if(relaxed.size() == 0) { env.error("Relaxed JSON should not be empty"); return; }
    if(canonical.size() == 0) { env.error("Canonical JSON should not be empty"); return; }
    env.success("as_json and as_canonical_json work")
}

@test
func test_document_to_string(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_utf8("name", "Heidi");
    var s = doc.to_string();
    if(s.size() == 0) { env.error("to_string should not be empty"); return; }
    env.success("Document to_string works")
}

// ========== OID Tests ==========

@test
func test_oid_generation(env : &mut TestEnv) {
    var oid = mongodb::OID();
    if(oid.is_null()) { env.error("Generated OID should not be null"); return; }
    var str = oid.to_string();
    if(str.size() != 24) { env.error("OID string should be 24 hex chars"); return; }
    env.success("OID generated correctly")
}

@test
func test_oid_generation_unique(env : &mut TestEnv) {
    var oid1 = mongodb::OID();
    var oid2 = mongodb::OID();
    if(oid1.is_equal(&oid2)) { env.error("Two generated OIDs should be different"); return; }
    env.success("OIDs are unique")
}

@test
func test_oid_from_string(env : &mut TestEnv) {
    var hex = std::string_view("507f1f77bcf86cd799439011");
    var oid = mongodb::OID.from_string(hex);
    var str = oid.to_string();
    if(!str.equals_view("507f1f77bcf86cd799439011")) { env.error("OID roundtrip failed"); return; }
    env.success("OID from_string works correctly")
}

@test
func test_oid_equality(env : &mut TestEnv) {
    var hex = std::string_view("507f1f77bcf86cd799439011");
    var oid1 = mongodb::OID.from_string(hex);
    var oid2 = mongodb::OID.from_string(hex);
    var oid3 = mongodb::OID();
    if(!oid1.is_equal(&oid2)) { env.error("Two OIDs from same string should be equal"); return; }
    if(oid1.is_equal(&oid3)) { env.error("Different OIDs should not be equal"); return; }
    env.success("OID equality works correctly")
}

@test
func test_oid_null_check(env : &mut TestEnv) {
    var zero = mongodb::OID.from_string("000000000000000000000000");
    if(!zero.is_null()) { env.error("Zero OID should be null"); return; }
    var oid = mongodb::OID();
    if(oid.is_null()) { env.error("Generated OID should not be null"); return; }
    env.success("OID null check works")
}

@test
func test_oid_to_view(env : &mut TestEnv) {
    var oid = mongodb::OID();
    var view = oid.to_view();
    if(view.size() != 12) { env.error("OID view should be 12 bytes"); return; }
    env.success("OID to_view works")
}

@test
func test_oid_multiple_from_string(env : &mut TestEnv) {
    var hex1 = std::string_view("507f1f77bcf86cd799439011");
    var hex2 = std::string_view("507f1f77bcf86cd799439012");
    var o1 = mongodb::OID.from_string(hex1);
    var o2 = mongodb::OID.from_string(hex2);
    if(o1.is_equal(&o2)) { env.error("Different OIDs should not be equal"); return; }
    env.success("Multiple OID from_string works")
}

// ========== Iteration Tests ==========

@test
func test_iteration(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_utf8("name", "Henry");
    doc.append_int32("age", 45);
    doc.append_bool("active", true);
    doc.append_double("score", 88.5);
    var it = doc.iter();
    var found_name = false;
    var found_age = false;
    var found_active = false;
    var found_score = false;
    var count = 0;
    while(it.next()) {
        count = count + 1;
        var k = it.key();
        if(k.equals("name")) { found_name = true; }
        else if(k.equals("age")) { found_age = true; }
        else if(k.equals("active")) { found_active = true; }
        else if(k.equals("score")) { found_score = true; }
    }
    if(count != 4) { env.error("Should have 4 fields"); return; }
    if(!found_name) { env.error("Should find 'name' field"); return; }
    if(!found_age) { env.error("Should find 'age' field"); return; }
    if(!found_active) { env.error("Should find 'active' field"); return; }
    if(!found_score) { env.error("Should find 'score' field"); return; }
    env.success("Iteration works correctly")
}

@test
func test_iteration_types(env : &mut TestEnv) {
    var doc = mongodb::Document();
    doc.append_int32("int32", 42);
    doc.append_int64("int64", 9999999999i64);
    doc.append_double("double", 3.14);
    doc.append_bool("bool", true);
    doc.append_utf8("string", "test");
    var it = doc.iter();
    var checks = 0;
    while(it.next()) {
        var k = it.key();
        if(k.equals("int32")) {
            if(it.int32() != 42) { env.error("int32 value wrong"); return; }
            checks = checks + 1;
        } else if(k.equals("int64")) {
            if(it.int64() != 9999999999i64) { env.error("int64 value wrong"); return; }
            checks = checks + 1;
        } else if(k.equals("double")) {
            if(it.double() < 3.13 || it.double() > 3.15) { env.error("double value wrong"); return; }
            checks = checks + 1;
        } else if(k.equals("bool")) {
            if(!it.bool()) { env.error("bool value wrong"); return; }
            checks = checks + 1;
        } else if(k.equals("string")) {
            if(!it.utf8().equals("test")) { env.error("string value wrong"); return; }
            checks = checks + 1;
        }
    }
    if(checks != 5) { env.error("Should have checked all 5 fields"); return; }
    env.success("Iteration type reads work correctly")
}

@test
func test_iter_empty_document(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var it = doc.iter();
    if(it.next()) { env.error("Empty doc iteration should yield nothing"); return; }
    env.success("Empty document iteration works")
}

@test
func test_iter_subdocument(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var sub = mongodb::Document();
    sub.append_utf8("city", "Chicago");
    sub.append_int32("zip", 60601);
    doc.append_document("address", &sub);
    var it = doc.iter();
    var found = false;
    while(it.next()) {
        if(it.key().equals("address")) {
            var inner = it.document();
            if(inner.is_null()) { env.error("Inner document should not be null"); return; }
            if(!inner.has_field("city")) { env.error("Inner doc should have 'city'"); return; }
            if(!inner.has_field("zip")) { env.error("Inner doc should have 'zip'"); return; }
            found = true;
        }
    }
    if(!found) { env.error("Should find 'address' field"); return; }
    env.success("Subdocument iteration works")
}

@test
func test_iter_array_field(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var arr = mongodb::Document();
    arr.append_utf8("0", "x");
    arr.append_utf8("1", "y");
    arr.append_utf8("2", "z");
    doc.append_array("letters", &arr);
    var it = doc.iter();
    var found = false;
    while(it.next()) {
        if(it.key().equals("letters")) {
            var inner = it.array();
            if(inner.is_null()) { env.error("Array document should not be null"); return; }
            found = true;
        }
    }
    if(!found) { env.error("Should find 'letters' array field"); return; }
    env.success("Array field iteration works")
}

@test
func test_iter_oid_field(env : &mut TestEnv) {
    var doc = mongodb::Document();
    var oid = mongodb::OID.from_string("507f1f77bcf86cd799439011");
    doc.append_oid("_id", &oid);
    var it = doc.iter();
    var found = false;
    while(it.next()) {
        if(it.key().equals("_id")) {
            var read_oid = it.oid();
            if(!read_oid.is_equal(&oid)) { env.error("OID roundtrip through iter failed"); return; }
            found = true;
        }
    }
    if(!found) { env.error("Should find '_id' field"); return; }
    env.success("OID iteration works")
}

// ========== URI Tests ==========

@test
func test_uri_parse_invalid(env : &mut TestEnv) {
    var uri = mongodb::Uri("mongodb://");
    if(uri.isValid()) { env.error("Invalid URI should not be valid"); return; }
    if(!uri.isInvalid()) { env.error("Invalid URI should be marked as invalid"); return; }
    env.success("Invalid URI correctly rejected")
}

@test
func test_uri_parse_valid(env : &mut TestEnv) {
    var uri = mongodb::Uri("mongodb://localhost:27017");
    if(uri.isInvalid()) { env.error("Valid URI should not be invalid"); return; }
    if(!uri.isValid()) { env.error("Valid URI should be valid"); return; }
    env.success("Valid URI accepted")
}

@test
func test_uri_parse_with_options(env : &mut TestEnv) {
    var uri = mongodb::Uri("mongodb://localhost:27017/?appname=test&retryWrites=true");
    if(uri.isInvalid()) { env.error("URI with options should be valid"); return; }
    env.success("URI with connection options accepted")
}

@test
func test_uri_parse_replica_set(env : &mut TestEnv) {
    var uri = mongodb::Uri("mongodb://host1:27017,host2:27017/?replicaSet=rs0");
    if(uri.isInvalid()) { env.error("Replica set URI should be valid"); return; }
    env.success("Replica set URI accepted")
}

@test
func test_uri_parse_auth(env : &mut TestEnv) {
    var uri = mongodb::Uri("mongodb://user:pass@localhost:27017/admin");
    if(uri.isInvalid()) { env.error("Auth URI should be valid"); return; }
    env.success("URI with auth credentials accepted")
}

// ========== Error Handling Tests ==========

@test
func test_error_handling(env : &mut TestEnv) {
    var e1 = mongodb::Error.Code(123);
    var s1 = e1.to_string();
    if(s1.size() == 0) { env.error("Error code string should not be empty"); return; }
    var e2 = mongodb::Error.Runtime("test error message");
    var s2 = e2.to_string();
    if(s2.size() == 0) { env.error("Runtime error string should not be empty"); return; }
    var e3 = mongodb::Error.Message(std::string("message error"));
    var s3 = e3.to_string();
    if(s3.size() == 0) { env.error("Message error string should not be empty"); return; }
    var e4 = mongodb::Error.Bson(1, 2, std::string("bson error"));
    var s4 = e4.to_string();
    if(s4.size() == 0) { env.error("Bson error string should not be empty"); return; }
    env.success("Error handling works")
}

@test
func test_error_variant_matching(env : &mut TestEnv) {
    var err = mongodb::Error.Code(42);
    var ok = false;
    switch(err) {
        Code(c) => { if(c == 42u32) { ok = true; } }
        default => {}
    }
    if(!ok) { env.error("Error variant matching failed"); return; }
    var err2 = mongodb::Error.Runtime("msg");
    switch(err2) {
        Runtime(m) => { ok = true; }
        default => { env.error("Runtime error variant matching failed"); return; }
    }
    env.success("Error variant matching works")
}

// ========== ReadPrefs / ReadConcern / WriteConcern Tests ==========

@test
func test_read_prefs(env : &mut TestEnv) {
    var primary = mongodb::ReadPrefs.new(mongodb::ReadMode.Primary);
    if(primary.is_null()) { env.error("Primary read prefs should not be null"); return; }
    var secondary = mongodb::ReadPrefs.new(mongodb::ReadMode.Secondary);
    if(secondary.is_null()) { env.error("Secondary read prefs should not be null"); return; }
    var nearest = mongodb::ReadPrefs.new(mongodb::ReadMode.Nearest);
    if(nearest.is_null()) { env.error("Nearest read prefs should not be null"); return; }
    env.success("ReadPrefs created correctly")
}

@test
func test_write_concern(env : &mut TestEnv) {
    var wc = mongodb::WriteConcern.new();
    if(wc.is_null()) { env.error("WriteConcern should not be null"); return; }
    wc.set_w(1);
    env.success("WriteConcern created and configured")
}

@test
func test_read_concern(env : &mut TestEnv) {
    var rc = mongodb::ReadConcern.new();
    if(rc.is_null()) { env.error("ReadConcern should not be null"); return; }
    rc.set_level("majority");
    env.success("ReadConcern created and configured")
}

@test
func test_read_concern_levels(env : &mut TestEnv) {
    var local = mongodb::ReadConcern.new();
    local.set_level("local");
    var majority = mongodb::ReadConcern.new();
    majority.set_level("majority");
    var linearizable = mongodb::ReadConcern.new();
    linearizable.set_level("linearizable");
    env.success("ReadConcern levels configured")
}

// ========== Driver Tests ==========

@test
func test_driver_version(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var ver = driver.get_version();
    if(ver == null) { env.error("Driver version should not be null"); return; }
    env.success("MongoDB driver initialized, version retrieved")
}

@test
func test_driver_multiple_instances(env : &mut TestEnv) {
    var d1 = mongodb::Driver();
    var d2 = mongodb::Driver();
    var v1 = d1.get_version();
    var v2 = d2.get_version();
    if(v1 == null || v2 == null) { env.error("Driver versions should not be null"); return; }
    env.success("Multiple driver instances work")
}
// ========== Integration Tests (require MongoDB on localhost:27017) ==========

@test
func test_connect_localhost(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        var Err(e) = res else unreachable;
        env.warning("Could not connect to MongoDB, skipping");
        env.info(e.to_string().data());
        return;
    }
    var Ok(client) = res else unreachable;
    if(client.is_null()) { env.error("Client should not be null"); return; }
    env.success("Connected to MongoDB at localhost:27017")
}

@test
func test_get_database(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    if(db.is_null()) { env.error("Database should not be null"); return; }
    env.success("get_database works")
}

@test
func test_list_databases(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var names_res = client.get_database_names();
    if(names_res is Result.Ok) {
        env.success("Listed databases successfully");
    } else {
        env.warning("Could not list databases (may be permission issue)")
    }
}

@test
func test_create_and_drop_collection(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var create_res = db.create_collection("test_create_drop");
    if(create_res is Result.Ok) {
        var Ok(coll) = create_res else unreachable;
        var has_res = db.has_collection("test_create_drop");
        if(has_res is Result.Ok) {
            var Ok(exists) = has_res else unreachable;
            if(!exists) { env.error("Collection should exist after create"); return; }
            var drop_res = coll.drop();
            if(drop_res is Result.Ok) {
                env.success("Create, check, and drop collection works");
                return;
            }
        }
    }
    env.error("Collection create/drop cycle failed")
}

@test
func test_crud_operations(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_crud");
    coll.delete_many(mongodb::Document());

    var doc = mongodb::Document();
    doc.append_utf8("name", "Integration");
    doc.append_int32("value", 42);
    var oid = mongodb::OID();
    doc.append_oid("_id", &oid);

    var insert_res = coll.insert_one(&doc);
    if(insert_res is Result.Err) { env.error("Insert failed"); return; }
    env.info("Insert succeeded");

    var count_res = coll.count_documents(mongodb::Document());
    if(count_res is Result.Err) { env.error("Count failed"); return; }
    var Ok(count) = count_res else unreachable;
    if(count <= 0) { env.error("Count should be > 0"); return; }

    var query = mongodb::Document();
    query.append_utf8("name", "Integration");
    var cursor = coll.find(&query);
    var found = false;
    while(true) {
        var next_res = cursor.next();
        if(next_res is Result.Err) { break; }
        var Ok(opt) = next_res else unreachable;
        var Some(found_doc) = opt else break;
        found = true;
    }
    if(!found) { env.error("Should find the inserted document"); return; }

    var update_selector = mongodb::Document();
    update_selector.append_utf8("name", "Integration");
    var update_doc = mongodb::Document();
    var set_doc = mongodb::Document();
    set_doc.append_int32("value", 43);
    update_doc.append_document("\\", &set_doc);
    var update_res = coll.update_one(&update_selector, &update_doc);
    if(update_res is Result.Err) { env.error("Update failed"); return; }

    var delete_res = coll.delete_one(&update_selector);
    if(delete_res is Result.Err) { env.error("Delete failed"); return; }
    env.success("Full CRUD cycle completed")
}

@test
func test_insert_many(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_insert_many");
    coll.delete_many(mongodb::Document());

    var docs = std::vector<mongodb::Document>();
    for(var i = 0; i < 5; i = i + 1) {
        var d = mongodb::Document();
        d.append_int32("index", i as i32);
        d.append_utf8("label", "item");
        docs.push_back(d);
    }

    var span_view = std::span<mongodb::Document>(docs.data(), docs.size());
    var insert_res = coll.insert_many(&span_view);
    if(insert_res is Result.Err) { env.error("insert_many failed"); return; }

    var count_res = coll.count_documents(mongodb::Document());
    if(count_res is Result.Ok) {
        var Ok(count) = count_res else unreachable;
        if(count != 5i64) { env.error("Should have 5 documents after insert_many"); return; }
        env.success("insert_many works correctly");
    } else {
        env.error("Count after insert_many failed")
    }
}

@test
func test_delete_many(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_delete_many");
    coll.delete_many(mongodb::Document());

    for(var i = 0; i < 3; i = i + 1) {
        var d = mongodb::Document();
        d.append_int32("val", i as i32);
        coll.insert_one(&d);
    }

    var del_res = coll.delete_many(mongodb::Document());
    if(del_res is Result.Err) { env.error("delete_many failed"); return; }

    var count_res = coll.count_documents(mongodb::Document());
    if(count_res is Result.Ok) {
        var Ok(count) = count_res else unreachable;
        if(count != 0i64) { env.error("Count should be 0 after delete_many"); return; }
        env.success("delete_many works correctly");
    } else {
        env.error("Count after delete_many failed")
    }
}

@test
func test_update_many(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_update_many");
    coll.delete_many(mongodb::Document());

    for(var i = 0; i < 3; i = i + 1) {
        var d = mongodb::Document();
        d.append_int32("val", i as i32);
        d.append_utf8("group", "a");
        coll.insert_one(&d);
    }

    var filter = mongodb::Document();
    filter.append_utf8("group", "a");
    var update = mongodb::Document();
    var set = mongodb::Document();
    set.append_utf8("group", "b");
    update.append_document("\\", &set);

    var update_res = coll.update_many(&filter, &update);
    if(update_res is Result.Err) { env.error("update_many failed"); return; }

    var count_res = coll.count_documents(mongodb::Document());
    if(count_res is Result.Ok) {
        var Ok(count) = count_res else unreachable;
        if(count != 3i64) { env.error("Count should still be 3 after update_many"); return; }
        env.success("update_many works correctly");
    } else {
        env.error("Count after update_many failed")
    }
}

@test
func test_replace_one(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_replace");
    coll.delete_many(mongodb::Document());

    var doc = mongodb::Document();
    doc.append_utf8("name", "original");
    doc.append_int32("val", 1);
    var oid = mongodb::OID();
    doc.append_oid("_id", &oid);
    coll.insert_one(&doc);

    var filter = mongodb::Document();
    filter.append_oid("_id", &oid);
    var replacement = mongodb::Document();
    replacement.append_utf8("name", "replaced");
    replacement.append_int32("val", 99);
    replacement.append_oid("_id", &oid);

    var replace_res = coll.replace_one(&filter, &replacement);
    if(replace_res is Result.Ok) {
        env.success("replace_one works correctly");
    } else {
        env.error("replace_one failed")
    }
}

@test
func test_aggregate(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_aggregate");
    coll.delete_many(mongodb::Document());

    for(var i = 1; i <= 5; i = i + 1) {
        var d = mongodb::Document();
        d.append_utf8("type", "item");
        d.append_int32("qty", i as i32);
        coll.insert_one(&d);
    }

    var pipeline = mongodb::Document();
    var match_stage = mongodb::Document();
    match_stage.append_utf8("type", "item");
    pipeline.append_document("\\", &match_stage);

    var agg_cursor = coll.aggregate(&pipeline);
    var found = 0;
    while(true) {
        var next = agg_cursor.next();
        if(next is Result.Err) break;
        var Ok(opt) = next else unreachable;
        if(opt is Option.None) break;
        var Some(d) = opt else unreachable;
        found = found + 1;
    }
    if(found != 5) { env.error("Should have found 5 docs from aggregate"); return; }
    env.success("Aggregate pipeline works")
}

@test
func test_estimated_document_count(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_est_count");
    coll.delete_many(mongodb::Document());

    for(var i = 0; i < 3; i = i + 1) {
        var d = mongodb::Document();
        d.append_int32("i", i as i32);
        coll.insert_one(&d);
    }

    var est_res = coll.estimated_document_count();
    if(est_res is Result.Ok) {
        var Ok(count) = est_res else unreachable;
        if(count <= 0) { env.error("Estimated count should be > 0"); return; }
        env.success("estimated_document_count works");
    } else {
        env.error("estimated_document_count failed")
    }
}

@test
func test_find_with_opts(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_find_opts");
    coll.delete_many(mongodb::Document());

    for(var i = 1; i <= 5; i = i + 1) {
        var d = mongodb::Document();
        d.append_utf8("name", "item");
        d.append_int32("order", i as i32);
        coll.insert_one(&d);
    }

    var filter = mongodb::Document();
    filter.append_utf8("name", "item");
    var cursor = coll.find(&filter);
    var found = 0;
    while(true) {
        var next_res = cursor.next();
        if(next_res is Result.Err) break;
        var Ok(opt) = next_res else unreachable;
        var Some(found_doc) = opt else break;
        found = found + 1;
    }
    if(found != 5) { env.error("Should find 5 docs"); return; }
    env.success("find works correctly")
}

@test
func test_create_index(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var coll = db.get_collection("test_indexes");
    coll.delete_many(mongodb::Document());

    var keys = mongodb::Document();
    keys.append_int32("name", 1);
    var index_res = coll.create_index(&keys);
    if(index_res is Result.Ok) {
        env.success("Index created successfully");
    } else {
        env.error("create_index failed")
    }
}

@test
func test_database_command_simple(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var ping = mongodb::Document();
    ping.append_int32("ping", 1);
    var cmd_res = db.command_simple(&ping);
    if(cmd_res is Result.Ok) {
        env.success("Ping command works");
    } else {
        env.error("Ping command failed")
    }
}

@test
func test_client_command_simple(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var cmd = mongodb::Document();
    cmd.append_int32("ping", 1);
    var cmd_res = client.command_simple("admin", &cmd);
    if(cmd_res is Result.Ok) {
        env.success("Client ping command works");
    } else {
        env.error("Client ping command failed")
    }
}

@test
func test_drop_collection(env : &mut TestEnv) {
    var driver = mongodb::Driver();
    var res = driver.create_client("mongodb://localhost:27017");
    if(res is Result.Err) {
        env.info("Integration test skipped: MongoDB not available");
        return;
    }
    var Ok(client) = res else unreachable;
    var db = client.get_database("chemical_test");
    var create_res = db.create_collection("test_drop_me");
    if(create_res is Result.Ok) {
        var drop_res = db.drop_collection("test_drop_me");
        if(drop_res is Result.Ok) {
            env.success("Database.drop_collection works");
        } else {
            env.error("drop_collection failed")
        }
    } else {
        env.error("create_collection for drop test failed")
    }
}
