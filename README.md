# Dynamic Decoding For Deeply-Nested JSON (Playground Demo)

This is an interactive **explanation + demo** of a small decoding utility that makes it easy to extract values buried deep inside gnarly JSON responses — without writing 20 layers of `structs` or a forest of `CodingKeys`.

---

Many of the JSON payloads we get from our APIs often nest the data we want several layers deep.  
Decoding these with standard `Decodable` means defining either **full intermediate models** or **multiple `CodingKey` hierarchies** just to reach a single value.

### Example JSON
````json
{
  "xo_metadata": {
    "entities": [
      {
        "terms": {
          "designer": {
            "id": "123",
            "name": "Lillian West"
          }
        }
      }
    ]
  }
}
````

To decode just "Lillian West" with traditional `Decodable`, you’d need multiple nested types or `CodingKey`s for `xo_metadata`, `entities`, `terms`, and `designer`.

---

This utility extends `JSONDecoder` with a `path` parameter that can directly navigate to deeply nested values using **Swift key paths** - no intermediate types required

### End Result
```swift
let name: String = try JSONDecoder().decode(
    String.self,
    from: data,
    path: \.xo_metadata.entities.0.terms.designer.name
)
```

---

## Explore More in the Playground

`Examples.playground` contains runnable code snippets and more in-depth explanations

- Open this project in Xcode.
- Open `Examples.playground` in the editor
- Switch to **Editor → Show Rendered Markup** in Xcode to view formatted explanations alongside the code snippets.
- You can run the code snippets in the playground and view the output in the console or Live View side bar.
- You can modify the examples or add your own to see how different paths behave.
