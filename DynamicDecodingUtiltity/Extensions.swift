import Foundation

// MARK: - Decoding Extensions
public extension JSONDecoder {
    /// Decodes a value of the given type from `data` located at a nested JSON path.
    ///
    /// This lets you pluck values from deeply nested JSON without defining the
    /// full intermediate model hierarchy. The `path` is a `KeyPath` into
    /// `DynamicDecodingContainer` (e.g., `\.xo_metadata.entities.0.terms.designer`).
    ///
    /// - Parameters:
    ///   - type: The concrete `Decodable` type to decode.
    ///   - data: The raw JSON payload.
    ///   - path: A `DynamicDecodingPath` describing the nested location.
    /// - Returns: A decoded instance of `type` found at `path`.
    /// - Throws: A `DecodingError` if traversal or decoding fails, or if the path
    ///           resolves to a value incompatible with `type`.
    func decode<T: Decodable>(_ type: T.Type, from data: Data, path: DynamicDecodingPath) throws -> T {
        try decode(DynamicDecodingContainer.self, from: data).decode(type, path: path)
    }
}

public extension UnkeyedDecodingContainer {
    /// ⚠️ **Work in Progress:** This extension for decoding via `DynamicDecodingPath`
    /// inside an unkeyed container is experimental and may change or be removed.
    ///
    /// Decodes a value of the given type from a nested location inside this unkeyed container.
    ///
    /// Use this when you are already inside an array and want to keep decoding
    /// relative to the current position using a path (e.g., to step deeper into
    /// an element’s substructure).
    ///
    /// - Parameters:
    ///   - type: The concrete `Decodable` type to decode.
    ///   - path: A `DynamicDecodingPath` describing the nested location relative
    ///           to the current unkeyed container.
    /// - Returns: A decoded instance of `type` found at `path`.
    /// - Throws: A `DecodingError` if traversal or decoding fails.
    mutating func decode<T: Decodable>(_ type: T.Type, path: DynamicDecodingPath) throws -> T {
        try DynamicDecodingContainer(from: self).decode(type, path: path)
    }
}

public extension KeyedDecodingContainer {
    /// ⚠️ **Work in Progress:** This extension for decoding via `DynamicDecodingPath`
    /// inside an unkeyed container is experimental and may change or be removed.
    ///
    /// Decodes a value of the given type from a nested location inside this keyed container.
    ///
    /// Use this when you are already inside an object and want to continue decoding
    /// deeper without creating intermediate models.
    ///
    /// - Parameters:
    ///   - type: The concrete `Decodable` type to decode.
    ///   - path: A `DynamicDecodingPath` describing the nested location relative
    ///           to the current keyed container.
    /// - Returns: A decoded instance of `type` found at `path`.
    /// - Throws: A `DecodingError` if traversal or decoding fails.
    func decode<T: Decodable>(_ type: T.Type, path: DynamicDecodingPath) throws -> T {
        try DynamicDecodingContainer(from: self).decode(type, path: path)
    }
}
