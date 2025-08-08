import Foundation

public struct LocalURLResource {
    let fileName: String
    let fileExtension: String
    
    public static func jsonResource(_ fileName: String) -> LocalURLResource {
        .init(fileName: fileName, fileExtension: "json")
    }
}

public func getData(from resource: LocalURLResource) throws -> Data {
    guard let fileUrl = Bundle.main.url(forResource: resource.fileName, withExtension: resource.fileExtension)
    else { throw NSError(domain: "FileNotFoundError", code: 1, userInfo: nil) }
    return try Data(contentsOf: fileUrl)
}
