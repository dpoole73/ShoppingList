import Foundation

struct StoreSection: Identifiable, Codable, Hashable {
    let id: String        // section name as ID (unique within a store)
    let name: String
    let order: Int
}

struct Store: Identifiable, Codable, Hashable {
    let id: String        // store name as ID
    let name: String
    var sections: [StoreSection]
}

struct ProductLocation: Identifiable, Codable, Hashable {
    let id: String        // product+store combo
    let productId: String
    let storeId: String
    let sectionId: String
}

struct ShoppingListItem: Identifiable, Codable {
    var id: UUID = UUID()
    var product: Product
    var isPurchased: Bool = false
}

struct ShoppingList: Identifiable, Codable {
    var id: UUID = UUID()
    var store: Store
    var items: [ShoppingListItem]
}
