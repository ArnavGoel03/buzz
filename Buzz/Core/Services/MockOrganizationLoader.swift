import Foundation

enum MockOrganizationLoader {
    static func load() -> [Organization] {
        guard let url = Bundle.main.url(forResource: "mockOrganizations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let orgs = try? JSONDecoder().decode([Organization].self, from: data)
        else { return [] }
        return orgs
    }
}
