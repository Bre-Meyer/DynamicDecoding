/*:
 # Dynamic Decoding for Deeply‑Nested JSON

 This page is an **interactive explanation + demo** of a tiny utility that lets you decode values **deep inside** messy JSON *without* defining the full model tree.

 **Public API teammates should use:**

 ```swift
 JSONDecoder().decode(T.self, from: data, path: \.some.nested.0.path.here)
 ```

 Where `path` is a **Swift KeyPath** into `DynamicDecodingContainer`. Arrays are addressed by an **integer segment** in the key path (e.g., `.0` for the first element).

 ---

 ## Why?

 - Big payload? Only need a couple fields? This keeps things **readable** and **fast** to write.
 - Avoids maintaining massive `CodingKeys` hierarchies for throwaway reads.
 - Still type‑safe: you get a real `Decodable` at the end.

 ---

 ## How paths work

 You build the path with regular **Swift key‑path syntax** into `DynamicDecodingContainer`:

 ```swift
 \.xo_metadata.entities.0.terms.designer.name
 ```

 This means: go to `xo_metadata` → `entities` (array) → element `0` → `terms` → `designer` → `name`.

 > **Note**: This page intentionally documents only the public entry point:
 > `JSONDecoder.decode(_:from:path:)`. There is also ongoing exploration of
 > path‑based nested decoding inside custom `init(from:)`, but that API is not yet public.

 ---

 ## Load the sample JSON
 The playground ships with a sample payload (`Resources/sampleJSON1.json`). Let's load it:
 */
import Foundation

// MARK: - Sample data loader
private enum Sample {
    static let url = Bundle.main.url(forResource: "sampleJSON1", withExtension: "json")!
    static let data = try! Data(contentsOf: url)
}

// A tiny model to prove we can decode real types, not just scalars
public struct Designer: Decodable {
    public let id: String
    public let name: String
}

/*:
 ---
 ## Example 1 — Grab a deeply‑nested **String**

 Read the product's designer **name** from a deep path without building intermediate models.
 */
do {
    let name: String = try JSONDecoder().decode(String.self,
                                                from: Sample.data,
                                                path: \.xo_metadata.entities.0.terms.designer.name)
    print("Designer name:", name)
} catch {
    print("Example 1 error:", error)
}

/*:
 ---
 ## Example 2 — Decode a **model** from a sub‑tree

 Same path, but decode into our `Designer` type directly.
 */
do {
    let designer: Designer = try JSONDecoder().decode(
        Designer.self,
        from: Sample.data,
        path: \.xo_metadata.entities.0.terms.designer
    )
    print("Designer object → id:", designer.id, "| name:", designer.name)
} catch {
    print("Example 2 error:", error)
}

/*:
 ---
 ## Example 3 — Arrays and indices

 Paths support array segments seamlessly. For instance, here we pull the first breadcrumb's label text.
 */
do {
    // Adjust the path if your payload orders breadcrumbs differently.
    let firstBreadcrumbLabel: String = try JSONDecoder().decode(String.self,
                                                                from: Sample.data,
                                                                path: \.xo_breadcrumb_structure.0.label_text)
    print("First breadcrumb label:", firstBreadcrumbLabel)
} catch {
    print("Example 3 error:", error)
}

/*:
 ---
 ## Example 4 — Error messages you can act on

 Give the decoder a **wrong path** to see how it fails. You should get a message that points to the failing segment.
 */
do {
    _ = try JSONDecoder().decode(String.self,
                                 from: Sample.data,
                                 path: \.page.data.this_key_does_not_exist)
    print("(Unexpected) decoded a value at a bad path")
} catch {
    print("Example 4 (expected failure):", error)
}

/*:
 ---
 ## When to use this vs full models
 - Use **path decoding** for one‑off fields, quick scripts, prototypes, or when upstream structure churns.
 - Use **full models** when you own the API, the schema is stable, or you’ll pass the data broadly through your app.

 ---
 ## Implementation sketch (high‑level)

 Under the hood, `JSONDecoder.decode(_:from:path:)` first decodes a lightweight `DynamicDecodingContainer`,
 then walks the path segments (keys or indices) to reach a sub‑tree, finally decoding `T` there.

 You don’t need to depend on any of this surface—just use the `JSONDecoder` extension above.

 ---
 ## Credits
 - Author: Mono
 - Audience: iOS team
 - Purpose: Make deep JSON reads ergonomic and type‑safe.
 */
