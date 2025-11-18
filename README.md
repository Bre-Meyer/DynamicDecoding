# Dynamic Decoding For Deeply-Nested JSON (Playground Demo)

This is an interactive **explanation + demo** of a small decoding utility that makes it easy to extract values buried deep inside gnarly JSON responses — without writing 20 layers of `structs` or a forest of `CodingKeys`.

---

Many of the JSON payloads we get from our APIs often nest the data we want several layers deep.  
Decoding these with standard `Decodable` means defining either **full intermediate models** or **multiple `CodingKey` hierarchies** just to reach a single value.

### Example JSON
````json
{
  "mission_log": {
    "entries": [
      {
        "crew": {
          "commander": {
            "id": "crew-01",
            "name": "Cmdr. Ayla Chen"
          }
        }
      }
    ]
  }
}
````

To decode just `"Cmdr. Ayla Chen"` with traditional `Decodable`, you’d need to define nested types and `CodingKey`s for `mission_log`, `entries`, `crew`, and `commander`.

This utility extends `JSONDecoder` with a `path` parameter that lets you jump straight to deeply nested values using **Swift key paths** – no intermediate types required.

### End Result
```swift
let name: String = try JSONDecoder().decode(
    String.self,
    from: data,
    path: \.mission_log.entries.0.crew.commander.name
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
