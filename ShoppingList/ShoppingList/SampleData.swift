//struct SampleData {
//    static let products: [Product] = [
//        Product(name: "Milk"),
//        Product(name: "Bread"),
//        Product(name: "Eggs"),
//        Product(name: "Apples"),
//        Product(name: "Chicken"),
//        Product(name: "Beef"),
//        Product(name: "Flour"),
//    ]
//    
//    static let localStore: Store = {
//        let sections = [
//            StoreSection(name: "Produce", order: 0),
//            StoreSection(name: "Bakery", order: 1),
//            StoreSection(name: "Dairy", order: 2),
//            StoreSection(name: "Meat", order: 3),
//            StoreSection(name: "Baking", order: 4),
//        ]
//        return Store(name: "My Local Store", sections: sections)
//    }()
//    
//    static let bigMart: Store = {
//        let sections = [
//            StoreSection(name: "Bakery", order: 0),
//            StoreSection(name: "Meat & Seafood", order: 1),
//            StoreSection(name: "Dairy & Eggs", order: 2),
//            StoreSection(name: "Fresh Produce", order: 3),
//            StoreSection(name: "Frozen Foods", order: 4),
//            StoreSection(name: "Baking", order: 5)
//        ]
//        return Store(name: "BigMart", sections: sections)
//    }()
//    
//    static var allStores: [Store] {
//        [localStore, bigMart]
//    }
//    
//    static let productLocations: [ProductLocation] = {
//        var mappings: [ProductLocation] = []
//        
//        // Local Store layout
//        mappings.append(ProductLocation(product: products[0], storeId: localStore.id, sectionId: localStore.sections[2].id)) // Milk → Dairy
//        mappings.append(ProductLocation(product: products[1], storeId: localStore.id, sectionId: localStore.sections[1].id)) // Bread → Bakery
//        mappings.append(ProductLocation(product: products[2], storeId: localStore.id, sectionId: localStore.sections[2].id)) // Eggs → Dairy
//        mappings.append(ProductLocation(product: products[3], storeId: localStore.id, sectionId: localStore.sections[0].id)) // Apples → Produce
//        mappings.append(ProductLocation(product: products[4], storeId: localStore.id, sectionId: localStore.sections[3].id)) // Chicken → Meat
//        mappings.append(ProductLocation(product: products[5], storeId: localStore.id, sectionId: localStore.sections[3].id)) // Beef → Meat
//        mappings.append(ProductLocation(product: products[6], storeId: localStore.id, sectionId: localStore.sections[4].id)) // Flour → Baking
//        
//        // BigMart layout
//        mappings.append(ProductLocation(product: products[0], storeId: bigMart.id, sectionId: bigMart.sections[2].id)) // Milk → Dairy & Eggs
//        mappings.append(ProductLocation(product: products[1], storeId: bigMart.id, sectionId: bigMart.sections[0].id)) // Bread → Bakery
//        mappings.append(ProductLocation(product: products[2], storeId: bigMart.id, sectionId: bigMart.sections[2].id)) // Eggs → Dairy & Eggs
//        mappings.append(ProductLocation(product: products[3], storeId: bigMart.id, sectionId: bigMart.sections[3].id)) // Apples → Fresh Produce
//        mappings.append(ProductLocation(product: products[4], storeId: bigMart.id, sectionId: bigMart.sections[1].id)) // Chicken → Meat & Seafood
//        mappings.append(ProductLocation(product: products[5], storeId: bigMart.id, sectionId: bigMart.sections[1].id)) // Beef → Meat & Seafood
//        mappings.append(ProductLocation(product: products[6], storeId: bigMart.id, sectionId: bigMart.sections[5].id)) // Flour → Baking
//        
//        return mappings
//    }()
//}
