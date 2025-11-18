// MARK: - Commander
/// Example model used in the playground to demonstrate decoding a sub-tree
/// into a strongly-typed Swift value.
public struct Commander: Codable {
    public let id: String
    public let name: String
    public let role: String
    public let agency: String
    public let profileUrl: String
}
