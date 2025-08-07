import Foundation

typealias DynamicDecodingPath = KeyPath<DynamicDecodingContainer, DynamicDecodingContainer>

extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data, path: DynamicDecodingPath) throws -> T {
        try decode(DynamicDecodingContainer.self, from: data)[keyPath: path].decode(type)
    }
}

@dynamicMemberLookup
enum DynamicDecodingContainer: Decodable {
    case error(Error)
    case root(decoder: Decoder)
    case keyed(container: KeyedDecodingContainer<DynamicCodingKey>, key: String)
    case unkeyed(container: UnkeyedDecodingContainer, index: Int)

    init(from decoder: Decoder) throws {
        self = .root(decoder: decoder)
    }

    subscript (dynamicMember path: String) -> DynamicDecodingContainer {
        guard let index = Int(path)
        else { return nestedContainer(withPath: path) }
        return nestedUnkeyedContainer(withIndex: index)
    }

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
}

// MARK: - Private Methods
extension DynamicDecodingContainer {
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

    private func goToIndex(_ index: Int, in container: inout UnkeyedDecodingContainer) throws {
        while container.currentIndex < index {
            _ = try container.decode(DynamicDecodingContainer.self)
        }
    }
}

// MARK: - Dynamic Coding Key
extension DynamicDecodingContainer {
    struct DynamicCodingKey: CodingKey {
        var intValue: Int?
        var stringValue: String
        init?(intValue: Int) { return nil }
        init(stringValue: String) { self.stringValue = stringValue }

        static func key(_ key: String) -> DynamicCodingKey {
            DynamicCodingKey(stringValue: key)
        }
    }

}
