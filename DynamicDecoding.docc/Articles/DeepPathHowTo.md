# Deep Path How‑To

This page collects practical recipes for common tasks.

## Pluck a single value

```swift
let name: String = try JSONDecoder().decode(
    String.self,
    from: data,
    path: \.xo_metadata.entities.0.terms.designer.name
)
```

## Decode a sub‑tree into a model

```swift
struct Designer: Decodable {
    let id: String
    let name: String
}

let d: Designer = try JSONDecoder().decode(
    Designer.self,
    from: data,
    path: \.xo_metadata.entities.0.terms.designer
)
```

## Index into arrays

```swift
let firstLabel: String = try JSONDecoder().decode(
    String.self,
    from: data,
    path: \.xo_breadcrumb_structure.0.label_text
)
```

## Error handling

If the path is wrong or types mismatch, the decoder throws. Make sure to surface the **failing path segment** in logs or UI to speed debugging.

```swift
do {
    _ = try JSONDecoder().decode(String.self, from: data, path: \.bad.key.path)
} catch {
    print("Decoding failed:", error) // should include the segment that failed
}
```

## When to use this vs full models

- Use **path decoding** for one‑off fields, prototypes, or frequently changing upstream shapes.
- Use **full models** when you own the API, the schema is stable, or values are used broadly across the app.