import Foundation
import SwiftUI

/// Stores all products, stores, and their locations
class ProductStore: ObservableObject {
    @Published var products: [Product]
    @Published var stores: [Store]
    @Published var productLocations: [ProductLocation]

    init(products: [Product], stores: [Store], productLocations: [ProductLocation]) {
        self.products = products
        self.stores = stores
        self.productLocations = productLocations
    }

    // MARK: - Helpers

    /// Returns the section where a product is located in a given store
    func location(for product: Product, in store: Store) -> StoreSection? {
        // Find the mapping for this product in this store
        if let mapping = productLocations.first(where: { $0.productId == product.id && $0.storeId == store.id }) {
            // Find the section in the store
            return store.sections.first(where: { $0.id == mapping.sectionId })
        }
        return nil
    }

    /// Returns all products for a given store and optionally filters by search text
    func products(for store: Store, searchText: String = "") -> [Product] {
        let filtered = products.filter { product in
            productLocations.contains(where: { $0.productId == product.id && $0.storeId == store.id })
        }
        if searchText.isEmpty { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    /// Returns all products in a given section of a store
    func products(in section: StoreSection, store: Store) -> [Product] {
        let productIds = productLocations
            .filter { $0.storeId == store.id && $0.sectionId == section.id }
            .map { $0.productId }

        return products.filter { productIds.contains($0.id) }
    }
}
