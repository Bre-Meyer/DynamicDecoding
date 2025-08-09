import Foundation

// MARK: - DynamicDecodingPath
/// A `KeyPath` into a `DynamicDecodingContainer` that represents a traversal path
/// to a nested value in a JSON payload.
///
/// Paths can combine keyed and unkeyed container segments. For example:
/// ```swift
/// \.xo_metadata.entities.0.terms.designer
/// ```
/// navigates through a keyed container `xo_metadata`, into the array `entities`
/// at index 0, then through keyed containers `terms` and `designer`.
public typealias DynamicDecodingPath = KeyPath<DynamicDecodingContainer, DynamicDecodingContainer>

// MARK: - DynamicDecodingContainer
/// A dynamic, navigable decoding container that can traverse JSON hierarchies
/// without defining intermediate `Decodable` model types.
///
/// This type wraps Swift's `Decoder` and container types (`KeyedDecodingContainer`
/// and `UnkeyedDecodingContainer`) and uses `@dynamicMemberLookup` to let you
/// express navigation as key-path segments. Key segments can be either:
/// - String keys for objects (keyed containers)
/// - Int indices for arrays (unkeyed containers)
///
/// Use together with `JSONDecoder.decode(_:from:path:)` to extract deeply nested
/// values directly.
@dynamicMemberLookup
public enum DynamicDecodingContainer: Decodable {
    /// An error state representing a failure during traversal or decoding.
    case error(Error)
    /// A container at the root `Decoder` level.
    case root(decoder: Decoder)
    /// A keyed container (object/dictionary) with a specific key for the next nested container or value.
    case keyed(container: KeyedDecodingContainer<DynamicCodingKey>, key: String)
    /// An unkeyed container (array) with a specific index for the next nested container or value.
    case unkeyed(container: UnkeyedDecodingContainer, index: Int)

    /// Creates a `DynamicDecodingContainer` at the root decoder.
    public init(from decoder: Decoder) throws {
        self = .root(decoder: decoder)
    }

    /// Creates a `DynamicDecodingContainer` from a keyed container context.
    /// - Throws: `DecodingError.dataCorrupted` if no key can be determined from the coding path.
    init<T>(from keyedContainer: KeyedDecodingContainer<T>) throws {
        guard let key = keyedContainer.codingPath.last?.stringValue
        else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: keyedContainer.codingPath,
                    debugDescription: "Cannot decode from KeyedDecodingContainer without a key"
                )
            )
        }
        let container = try keyedContainer.superDecoder().container(keyedBy: DynamicCodingKey.self)
        self = .keyed(container: container, key: key)
    }

    /// Creates a `DynamicDecodingContainer` from an unkeyed container context.
    init(from unkeyedContainer: UnkeyedDecodingContainer) throws {
        var unkeyedContainer = unkeyedContainer
        let container = try unkeyedContainer.superDecoder().unkeyedContainer()
        self = .unkeyed(container: container, index: unkeyedContainer.currentIndex)
    }

    /// Dynamically navigates to a nested container by key or index.
    ///
    /// If the `path` string can be converted to an integer, it is treated as
    /// an array index; otherwise it is treated as a dictionary key.
    subscript(dynamicMember path: String) -> DynamicDecodingContainer {
        guard let index = Int(path)
        else { return nestedContainer(withPath: path) }
        return nestedUnkeyedContainer(withIndex: index)
    }

    /// Decodes a value of the specified type from the current container position.
    ///
    /// - Throws: Any decoding error that occurs while reading the value.
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        switch self {
        case let .error(error):
            throw error
        case let .root(decoder):
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot decode from root decoder"
                )
            )
        case let .keyed(container, key):
            return try container.decode(T.self, forKey: .key(key))
        case var .unkeyed(container, index):
            try goToIndex(index, in: &container)
            return try container.decode(T.self)
        }
    }

    /// Traverses to a nested path and decodes a value of the specified type.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - path: The key path describing the nested location in the JSON.
    public func decode<T: Decodable>(_ type: T.Type, path: DynamicDecodingPath) throws -> T {
        try self[keyPath: path].decode(T.self)
    }
}

// MARK: - Private traversal helpers
extension DynamicDecodingContainer {
    /// Navigates into a keyed container (object/dictionary)  with a specific key for the next nested container or value.
    private func nestedContainer(withPath path: String) -> DynamicDecodingContainer {
        do {
            switch self {
            case .error: return self
            case let .root(decoder):
                let nestedContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
                return .keyed(container: nestedContainer, key: path)
            case let .keyed(container, key):
                let nestedContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .key(key))
                return .keyed(container: nestedContainer, key: path)
            case var .unkeyed(container, index):
                try goToIndex(index, in: &container)
                let nestedContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self)
                return .keyed(container: nestedContainer, key: path)
            }
        } catch {
            return .error(error)
        }
    }

    /// Navigates into an unkeyed container (array)  with a specific index for the next nested container or value.
    private func nestedUnkeyedContainer(withIndex path: Int) -> DynamicDecodingContainer {
        do {
            switch self {
            case .error: return self
            case let .root(decoder):
                let nestedContainer = try decoder.unkeyedContainer()
                return .unkeyed(container: nestedContainer, index: path)
            case let .keyed(container, key):
                let nestedContainer = try container.nestedUnkeyedContainer(forKey: .key(key))
                return .unkeyed(container: nestedContainer, index: path)
            case var .unkeyed(container, index):
                try goToIndex(index, in: &container)
                let nestedContainer = try container.nestedUnkeyedContainer()
                return .unkeyed(container: nestedContainer, index: path)
            }
        } catch {
            return .error(error)
        }
    }

    /// Advances an unkeyed container's cursor to the specified index by decoding and discarding intermediate elements.
    private func goToIndex(_ index: Int, in container: inout UnkeyedDecodingContainer) throws {
        while container.currentIndex < index {
            _ = try container.decode(DynamicDecodingContainer.self)
        }
    }
}

// MARK: - DynamicCodingKey
extension DynamicDecodingContainer {
    /// A flexible coding key type for dynamic traversal.
    ///
    /// `DynamicCodingKey` can represent any string key and is used internally to
    /// access nested keyed containers without a predefined `CodingKeys` enum.
    public struct DynamicCodingKey: CodingKey {
        public var intValue: Int?
        public var stringValue: String
        public init?(intValue: Int) { return nil }
        public init(stringValue: String) { self.stringValue = stringValue }

        /// Creates a `DynamicCodingKey` from a string.
        static func key(_ key: String) -> DynamicCodingKey {
            DynamicCodingKey(stringValue: key)
        }
    }
}
