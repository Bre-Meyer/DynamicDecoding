import Foundation

// MARK: - Decoding Extensions
extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data, path: DynamicDecodingPath) throws -> T {
        try decode(DynamicDecodingContainer.self, from: data).decode(type, path: path)
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode<T: Decodable>(_ type: T.Type, path: DynamicDecodingPath) throws -> T {
        try DynamicDecodingContainer(from: self).decode(type, path: path)
    }
}

extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ type: T.Type, path: DynamicDecodingPath) throws -> T {
        try DynamicDecodingContainer(from: self).decode(type, path: path)
    }
}
