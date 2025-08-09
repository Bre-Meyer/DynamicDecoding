/*:
 # Dynamic Decoding for Deeply‑Nested JSON

 This page is an interactive **explanation + demo** of a small decoding utility that makes it easy to extract values buried deep inside gnarly JSON responses — without writing 20 layers of `structs` or a forest of `CodingKeys`.

 ```swift
 JSONDecoder().decode(T.self, from: data, path: \.some.nested.path.here)
 ```

 Where `path` is a **Swift KeyPath** into `DynamicDecodingContainer`. Arrays are addressed by an **integer segment** in the key path (e.g., `.0` for the first element).

 ---

 > Switch to **Editor → Show Rendered Markup** view formatted explanations alongside the code snippets.
 > You can run the code snippets in the playground and view the output in the console or Live View side bar.
 > You can modify the examples or add your own to see how different paths behave.

 ### Why?

 - Big payload? Only need a couple fields? This keeps things **readable** and **fast** to write.
 - Avoids maintaining massive `CodingKeys` hierarchies for throwaway reads.
 - Still type‑safe: you get a real `Decodable` at the end.

 ---

 ### How paths work

 You build the path with regular **Swift key‑path syntax** into `DynamicDecodingContainer`:

 ```swift
 \.xo_metadata.entities.0.terms.designer.name
 ```

 This means: go to `xo_metadata` → `entities` (array) → element `0` → `terms` → `designer` → `name`.

 > **Note**: This page intentionally documents only the entry point:
 > `JSONDecoder.decode(_:from:path:)`. There is also ongoing exploration of
 > path‑based nested decoding inside custom `init(from:)`, but that extension is still WIP.

 ---

 ### Models and Helpers
 The `Designer` model type and `getData` helper function used in these examples
 are located in the `Sources` folder of the playground.

 ### Setup
 Here we load a sample JSON payload from the playground’s `Resources` folder.
 You can open `sampleJSON1.json` in the navigator to inspect its structure.
 The examples below will reference this data when demonstrating path-based decoding.
 */
import Foundation

var data: Data
do {
    data = try getData(from: .jsonResource("sampleJSON1"))
} catch {
    print(error)
    fatalError("Couldn't load sample JSON data.")
}
/*:
 ---

 ## Example 1 — Grab a deeply‑nested **String**

 Decode the **description** of the social sharing data from a deep path without building intermediate models.
 */
do {
    let description: String = try JSONDecoder().decode(
        String.self,
        from: data,
        path: \.social_sharing_data.data_fields.description
    )
    print("Description:", description)
} catch {
    print("Example 1 error:", error)
}
/*:
 ---

 ## Example 2 — Arrays and indices

 Paths support array segments. For instance, here we pull the **name** of the designer in the first entity.
 */
do {
    let name: String = try JSONDecoder().decode(
        String.self,
        from: data,
        path: \.xo_metadata.entities.0.terms.designer.name
    )
    print("Designer name:", name)
} catch {
    print("Example 2 error:", error)
}
/*:
 ---

 ## Example 3 — Decode a **model** from a sub‑tree

 Same path, but decode into our `Designer` type directly.
 */
do {
    let designer: Designer = try JSONDecoder().decode(
        Designer.self,
        from: data,
        path: \.xo_metadata.entities.0.terms.designer
    )
    print("Designer object → id:", designer.id, "| url:", designer.url)
} catch {
    print("Example 3 error:", error)
}
/*:
 ---

 ## Example 4 — Errors are propogated just like regular decoding

 Give the decoder a **wrong path** to see how it fails. You should get a message that points to the failing segment.
 */
do {
    _ = try JSONDecoder().decode(
        String.self,
        from: data,
        path: \.page.data.this_key_does_not_exist
    )
    print("(Unexpected) decoded a value at a bad path")
} catch {
    print("Example 4 (expected failure):", error)
}
/*:
 ---

 ## Example 5 — DIY

 Test out your own paths or json data
 */
do {
    let value = try JSONDecoder().decode(
        String.self,
        from: data,
        path: \.some.path.here
    )
    print("Label:", value)
} catch {
    print("Example 5 error:", error)
}
