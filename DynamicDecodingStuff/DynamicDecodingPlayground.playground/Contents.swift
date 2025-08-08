import Foundation

// MARK: - Constants
private enum Constants {
    static let fileName: String = "sampleJSON1"
    static let fileExtension: String = "json"
}

guard let fileURL = Bundle.main.url(forResource: Constants.fileName, withExtension: Constants.fileExtension)
else { fatalError("Couldn't find '\(Constants.fileName).\(Constants.fileExtension)' in the main bundle.") }

do {
    let data = try Data(contentsOf: fileURL)
    let jsonDecoder = JSONDecoder()

    let model = try jsonDecoder.decode(Designer.self, from: data, path: \.xo_metadata.entities.0.terms.designer)
} catch {
    print(error)
}
