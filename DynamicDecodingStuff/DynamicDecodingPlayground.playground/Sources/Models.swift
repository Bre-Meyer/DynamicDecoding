// MARK: - Designer
public struct Designer: Codable {
    public let id: String
    public let name: String
    public let dataSource: String
    public let url: String
    public let listingUrl: String
    public let slug: String
    public let visible: Bool
    public let updatedAt: String
    public let parentCompanyId: String
    public let showPrices: Bool

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case dataSource
        case url
        case listingUrl
        case slug
        case visible
        case updatedAt
        case parentCompanyId
        case showPrices
    }

    public init(id: String, name: String, dataSource: String, url: String, listingUrl: String, slug: String, visible: Bool, updatedAt: String, parentCompanyId: String, showPrices: Bool) {
        self.id = id
        self.name = name
        self.dataSource = dataSource
        self.url = url
        self.listingUrl = listingUrl
        self.slug = slug
        self.visible = visible
        self.updatedAt = updatedAt
        self.parentCompanyId = parentCompanyId
        self.showPrices = showPrices
    }
}
