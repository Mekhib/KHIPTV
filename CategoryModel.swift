import SwiftData
import Foundation

struct CategoryDTO: Codable {
    let categoryId: String
    let categoryName: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
    }
}

@Model
final class Category {
    @Attribute(.unique) var categoryId: String
    var name: String
    var typeRaw: String 
    
    init(categoryId: String, name: String, type: CategoryType) {
        self.categoryId = categoryId
        self.name = name
        self.typeRaw = type.rawValue
    }
    
    var type: CategoryType {
        CategoryType(rawValue: typeRaw) ?? .movie
    }
}

enum CategoryType: String, Codable {
    case live, movie, series
}