# mongodb

MongoDB C driver bindings to Chemical, This links the driver dynamically

## Running Tests

Build and run the test suite:

```bash
cmake-build-debug/TCCCompiler lang/compiled/mongodb/chemical.mod -o build/test.exe --test --no-cache
./build/test.exe
```

Note: `--no-cache` is currently required to ensure new/changed tests are picked up — work is being done to fix cache invalidation so `--no-cache` can eventually be omitted.

## Usage

In your Chemical Mod

```chmod
import "github.com/chemicallang/mongodb"
```

## Example

```chemical
using mongodb;
using std::Result;
using std::Option;

public func main() : int {
    
    var driver = mongodb::Driver();
    printf("MongoDB driver initialized, version: %s\n", driver.get_version());

    // 2. Create a connection URI
    var uri_str = "mongodb://localhost:27017"
    var uri = mongodb::Uri(uri_str);
    if(uri.isInvalid()) {
        printf("Failed to parse URI: %s\n", uri_str);
        return 1;
    }

    // 3. Create a client via the driver (factory pattern)
    // This ensures the driver stays alive as long as the client is needed
    var client_res = driver.create_client_from_uri(uri);
    if(client_res is Result.Err) {
        var Err(e) = client_res else unreachable;
        printf("Failed to connect to MongoDB: %s\n", e.to_string().data());
        return 1;
    }
    var Ok(client) = client_res else unreachable
    printf("Connected to MongoDB!\n");

    // 4. Get a database and collection
    var db = client.get_database("testdb");
    
    // 4b. List collections
    printf("Collections in 'testdb':\n");
    var coll_names_res = db.get_collection_names();
    switch(coll_names_res) {
        Ok(value) => {
            for(var i : size_t = 0; i < value.size(); i = i + 1) {
                printf("  - %s\n", value.get(i).data());
            }
        }
        Err(error) => printf("  Error listing collections: %s\n", error.to_string().data())
    }

    var coll = db.get_collection("testcoll");
    printf("Got collection 'testdb.testcoll'\n");

    // 5. Insert many documents
    printf("Inserting multiple documents...\n");
    var docs = std::vector<mongodb::Document>();
    
    var doc1 = mongodb::Document();
    doc1.append_utf8("name", "Alice");
    doc1.append_int32("age", 30);
    docs.push_back(doc1);

    var doc2 = mongodb::Document();
    doc2.append_utf8("name", "Bob");
    doc2.append_int32("age", 35);
    docs.push_back(doc2);

    const docs_view = std::span<mongodb::Document>(docs.data(), docs.size());
    var insert_many_res = coll.insert_many(docs_view);
    switch(insert_many_res) {
        Ok => printf("Successfully inserted %d documents!\n", docs.size() as int)
        Err(error) => printf("Error inserting many: %s\n", error.to_string().data())
    }

    // 5c. Insert a document (original example)

    var doc = mongodb::Document();
    doc.append_utf8("name", "Chemical User");
    doc.append_int32("age", 25);
    doc.append_bool("is_pro", true);
    
    var oid = mongodb::OID();
    doc.append_oid("_id", oid);
    const oid_str = oid.to_string();
    printf("Inserting document with OID: %s\n", oid_str.data());

    var insert_res = coll.insert_one(doc);
    switch(insert_res) {
        Ok => printf("Successfully inserted document!\n")
        Err(error) => printf("Error inserting document: %s\n", error.to_string().data())
    }

    // 5b. Count documents
    var count_res = coll.count_documents(mongodb::Document());
    switch(count_res) {
        Ok(value) => printf("Collection count: %d\n", value as int)
        Err(error) => printf("Error counting: %s\n", error.to_string().data())
    }

    // 6. Query the document
    var query = mongodb::Document();
    query.append_utf8("name", "Chemical User");

    printf("Querying for documents where name is 'Chemical User'...\n");
    var cursor = coll.find(query);
    
    var found_count = 0;
    while(true) {
        var next_res = cursor.next();
        if(next_res is Result.Err) {
            var Err(error) = next_res else unreachable;
            printf("Cursor error: %s\n", error.to_string().data());
            break;
        }
        var Ok(opt_doc) = next_res else unreachable
        if(opt_doc is Result.Err) break;
        var Some(found_doc) = opt_doc else unreachable;
        
        printf("Found document (Relaxed JSON): %s\n", found_doc.as_json().data());
        printf("Found document (Canonical JSON): %s\n", found_doc.as_canonical_json().data());
        
        var it = found_doc.iter();
        while(it.next()) {
            printf("  Field: %s (Type: %d)\n", it.key().data(), it.type());
            if(it.key().equals("name")) {
                printf("    Value: %s\n", it.utf8().data());
            } else if(it.key().equals("age")) {
                printf("    Value: %d\n", it.int32());
            }
        }
        found_count = found_count + 1;
    }
    printf("Found %d document(s) via cursor.\n", found_count);

    // 6b. Aggregate example
    printf("Running aggregate query...\n");
    var pipeline = mongodb::Document();
    var match_stage = mongodb::Document();
    match_stage.append_utf8("name", "Chemical User");
    pipeline.append_document("$match", match_stage);
    
    var agg_cursor = coll.aggregate(pipeline);
    while(true) {
        var next = agg_cursor.next();
        if(next is Result.Err) break;
        var Ok(opt) = next else unreachable;
        if(opt is Option.None) break;
        var Some(d) = opt else unreachable;
        printf("Agg result: %s\n", d.as_json().data());
    }

    // 7. Update the document
    var update_selector = mongodb::Document();
    update_selector.append_oid("_id", oid);

    var update_doc = mongodb::Document();
    var set_doc = mongodb::Document();
    set_doc.append_int32("age", 26);
    update_doc.append_document("$set", set_doc);

    printf("Updating age to 26 for OID: %s\n", oid_str.data());
    var update_res = coll.update_one(update_selector, update_doc);
    switch(update_res) {
        Ok => printf("Successfully updated document!\n")
        Err(error) => printf("Error updating document: %s\n", error.to_string().data())
    }

    // 8. Delete the document
    printf("Deleting document with OID: %s\n", oid_str.data());
    var delete_res = coll.delete_one(update_selector);
    switch(delete_res) {
        Ok => printf("Successfully deleted document!\n")
        Err(error) => printf("Error deleting document: %s\n", error.to_string().data())
    }

    printf("Demo finished. Driver instance will now cleanup automatically.\n");
    return 0;
}
```