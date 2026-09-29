import Foundation
import SwiftData

enum LiveTVViewMode {
    case guide 
    case grid  
}

struct ChannelCategoryItem: Identifiable, Hashable {
    let id: String
    let name: String
    let flagEmoji: String?
    let iconName: String?
    let channelCount: Int
    let type: CategoryType
    
    enum CategoryType: Hashable {
        case favorites
        case recents
        case country(prefix: String)
        case custom(name: String)
    }
}

extension Channel {
    var countryPrefix: String {
        if let categoryName = self.categoryName, categoryName.contains("|") {
            return categoryName.components(separatedBy: "|").first?.trimmingCharacters(in: .whitespaces) ?? "US"
        }
        return "US"
    }
    
    var badgeTags: [String] {
        var tags: [String] = []
        if name.contains("4K") { tags.append("4K") }
        else if name.contains("HD") || name.contains("FHD") { tags.append("HD") }
        tags.append("EPG")
        return tags
    }
}