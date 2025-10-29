import Foundation
import SwiftUI

class ShoppingListStore: ObservableObject {
    @Published var list: ShoppingList {
        didSet {
            saveList()
        }
    }
    
    private static let storagePrefix = "shoppingList_"
    
    init(store: Store) {
        if let savedList = Self.loadList(for: store) {
            self.list = savedList
        } else {
            self.list = ShoppingList(store: store, items: [])
        }
    }
    
    /// Switches the active store and loads the saved list for that store (or creates a new empty list).
    func setStore(_ store: Store) {
        // only change if different store
        if store.id != list.store.id {
            if let loaded = Self.loadList(for: store) {
                self.list = loaded
            } else {
                self.list = ShoppingList(store: store, items: [])
            }
        }
    }
    
    func addProduct(_ product: Product) {
        // avoid duplicate product entries by product.id
        if !list.items.contains(where: { $0.product.id == product.id }) {
            let newItem = ShoppingListItem(product: product)
            list.items.append(newItem)
        }
    }
    
    /// Toggle purchased state for an item
    func togglePurchased(_ item: ShoppingListItem) {
        if let idx = list.items.firstIndex(where: { $0.id == item.id }) {
            list.items[idx].isPurchased.toggle()
        }
    }
    
    /// Remove items by their UUIDs
    func deleteItems(withIDs ids: [UUID]) {
        list.items.removeAll { ids.contains($0.id) }
    }
    
    /// Helper for onDelete within a section: offsets are indexes into the `itemsInSection` passed by the caller.
    /// The caller should map offsets to actual item IDs and call this, OR use this helper that accepts offsets and the items array.
    func removeItems(at offsets: IndexSet, in itemsInSection: [ShoppingListItem]) {
        let idsToDelete = offsets.compactMap { idx -> UUID? in
            guard idx >= 0 && idx < itemsInSection.count else { return nil }
            return itemsInSection[idx].id
        }
        deleteItems(withIDs: idsToDelete)
    }
    
    /// Remove all purchased items
    func clearPurchased() {
        list.items.removeAll { $0.isPurchased }
    }
    
    // MARK: - Persistence (UserDefaults)
    
    private func saveList() {
        let key = Self.storagePrefix + list.store.id
        do {
            let data = try JSONEncoder().encode(list)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save ShoppingList for store \(list.store.name):", error)
        }
    }
    
    private static func loadList(for store: Store) -> ShoppingList? {
        let key = storagePrefix + store.id
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(ShoppingList.self, from: data)
            return decoded
        } catch {
            print("Failed to load ShoppingList for store \(store.name):", error)
            return nil
        }
    }
}
