import Foundation

struct CSVLoader {
    static func loadProducts(from filename: String) -> ([Store], [Product], [ProductLocation]) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "csv") else {
            print("❌ CSV file not found")
            return ([], [], [])
        }

        do {
            let content = try String(contentsOf: url)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            guard lines.count > 1 else { return ([], [], []) }

            let header = lines[0].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

            // Expect: product_name, safeway_section, safeway_order, traderjoes_section, traderjoes_order
            var stores: [Store] = []
            var products: [Product] = []
            var productLocations: [ProductLocation] = []

            // Automatically detect store name pairs from header
            let storePairs = stride(from: 1, to: header.count, by: 2).compactMap { i -> (String, Int, Int)? in
                guard i + 1 < header.count else { return nil }
                let storeName = header[i].replacingOccurrences(of: "_section", with: "").capitalized
                return (storeName, i, i + 1)
            }

            // Create stores
            for (name, _, _) in storePairs {
                stores.append(Store(id: name, name: name, sections: []))
            }

            // Parse rows
            for line in lines.dropFirst() {
                let cols = line.split(separator: ",", omittingEmptySubsequences: false).map { $0.trimmingCharacters(in: .whitespaces) }
                if cols.isEmpty { continue }

                let productName = cols[0]
                let product = Product(id: productName, name: productName)
                products.append(product)

                for (storeName, sectionCol, orderCol) in storePairs {
                    guard sectionCol < cols.count else { continue }
                    let sectionName = cols[sectionCol]
                    guard !sectionName.isEmpty else { continue }

                    let order = Int(cols[orderCol]) ?? 999

                    if let storeIndex = stores.firstIndex(where: { $0.name == storeName }) {
                        // Create or reuse section
                        if !(stores[storeIndex].sections.contains { $0.id == sectionName }) {
                            let section = StoreSection(id: sectionName, name: sectionName, order: order)
                            stores[storeIndex].sections.append(section)
                        }

                        let sectionId = sectionName
                        let locId = "\(productName)-\(storeName)"
                        let loc = ProductLocation(
                            id: locId,
                            productId: productName,
                            storeId: storeName,
                            sectionId: sectionId
                        )
                        productLocations.append(loc)
                    }
                }
            }

            // Sort sections within each store
            for i in stores.indices {
                stores[i].sections.sort(by: { $0.order < $1.order })
            }

            return (stores, products, productLocations)

        } catch {
            print("❌ Error reading CSV: \(error)")
            return ([], [], [])
        }
    }
}
