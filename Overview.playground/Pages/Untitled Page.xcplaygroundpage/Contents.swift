import Foundation

// MARK: - Constants
private enum Example1 {
    static let fileName: String = "sampleJSON1"
    static let fileExtension: String = "json"
}

do {
    let data = try getData(from: .jsonResource(Example1.fileName))
    let jsonDecoder = JSONDecoder()

    let model = try jsonDecoder.decode(Designer.self, from: data, path: \.xo_metadata.entities.0.terms.designer)
} catch {
    print(error)
}
