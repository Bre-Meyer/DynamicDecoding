# Getting Started

This guide introduces the public API and shows a minimal end‑to‑end example.

## Public API

Teammates should use the `JSONDecoder` extension:

```swift
try JSONDecoder().decode(T.self, from: data, path: \.xo_metadata.entities.0.terms.designer)
```

- The `path` parameter is a **Swift key path** into `DynamicDecodingContainer`.
- Array indices are written like normal key‑path segments using integers (e.g. `.0`).

## Minimal Example

```swift
import Foundation

struct Designer: Decodable {
    let id: String
    let name: String
}

let data = /* Data from your JSON payload */

let designer: Designer = try JSONDecoder().decode(
    Designer.self,
    from: data,
    path: \.xo_metadata.entities.0.terms.designer
)

print(designer.name)
```

> Tip: For runnable code, open the accompanying playground and try the “Decode a model from a sub‑tree” section.