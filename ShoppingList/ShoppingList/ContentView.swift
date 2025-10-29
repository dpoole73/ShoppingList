import SwiftUI

struct ContentView: View {
    
    enum SampleData {
        static let (allStores, products, productLocations) = CSVLoader.loadProducts(from: "products")
    }
    
    @StateObject private var productStore = ProductStore(
        products: SampleData.products,
        stores: SampleData.allStores,
        productLocations: SampleData.productLocations
    )
    @StateObject private var listStore = ShoppingListStore(store: SampleData.allStores.first!)
    @State private var selectedStore: Store = SampleData.allStores.first!
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @FocusState private var searchFieldFocused: Bool
    @State private var showAddSection = true
    
    

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Store Picker
                Picker("Select Store", selection: $selectedStore) {
                    ForEach(productStore.stores) { store in
                        Text(store.name).tag(store)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedStore) { newStore in
                    listStore.setStore(newStore)
                }

                Divider()

                // Search + Dropdown (ZStack so dropdown overlays list)
                // Search + Dropdown (fixed behavior)
                // MARK: - Add Product Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Add Products")
                            .font(.headline)
                        Spacer()
                        Button {
                            withAnimation {
                                showAddSection.toggle()
                                isSearching = false
                                searchText = ""
                                searchFieldFocused = false
                            }
                        } label: {
                            Label(showAddSection ? "Done" : "Add", systemImage: showAddSection ? "chevron.up" : "plus")
                                .labelStyle(.titleAndIcon)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)

                    if showAddSection {
                        VStack(spacing: 0) {
                            TextField("Search or add product", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .focused($searchFieldFocused)
                                .onTapGesture {
                                    withAnimation { isSearching = true }
                                }
                                .onChange(of: searchText) { _ in
                                    withAnimation { isSearching = true }
                                }

                            if isSearching {
                                ScrollView {
                                    VStack(spacing: 0) {
                                        ForEach(filteredProducts, id: \.id) { product in
                                            Button {
                                                listStore.addProduct(product)
                                                searchText = ""
                                                withAnimation { isSearching = false }
                                                searchFieldFocused = false
                                            } label: {
                                                HStack {
                                                    Text(product.name)
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                    if let sectionName = sectionName(for: product) {
                                                        Text(sectionName)
                                                            .foregroundColor(.secondary)
                                                            .italic()
                                                    }
                                                }
                                                .padding(.horizontal)
                                                .padding(.vertical, 10)
                                            }
                                            Divider()
                                        }

                                        if filteredProducts.isEmpty {
                                            Text("No matching products")
                                                .foregroundColor(.secondary)
                                                .padding()
                                        }
                                    }
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                }
                                .frame(maxHeight: 200)
                                .transition(.opacity)
                            }
                        }
                        .padding(.bottom, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))
                .zIndex(5)


                // Sectioned Shopping List — make it take remaining space so it's scrollable
                List {
                    ForEach(sectionedItems(), id: \.0.id) { section, items in
                        Section(header: Text(section.name)) {
                            ForEach(items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.product.name)
                                            .strikethrough(item.isPurchased)
                                            .foregroundColor(item.isPurchased ? .secondary : .primary)
                                        if let sectionName = sectionName(for: item.product) {
                                            Text(sectionName)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    Spacer()

                                    if item.isPurchased {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }

                                    Button(action: {
                                        // delete this item
                                        listStore.deleteItems(withIDs: [item.id])
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .imageScale(.medium)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .padding(.leading, 8)
                                }
                                .contentShape(Rectangle()) // make whole row tappable
                                .onTapGesture {
                                    listStore.togglePurchased(item)
                                }
                            }
                            .onDelete { offsets in
                                // offsets are indexes into `items` (section's array)
                                listStore.removeItems(at: offsets, in: items)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity) // <-- important: take remaining space
            }
            .navigationTitle("Shopping List")
            .onAppear {
                listStore.setStore(selectedStore)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear Purchased") {
                        listStore.clearPurchased()
                    }
                    .disabled(!listStore.list.items.contains(where: { $0.isPurchased }))
                }
            }
        }
    }

    // MARK: - Helpers

    /// Suggest products: if search text empty show all products (or some subset)
//    var filteredProducts: [Product] {
//        let all = productStore.products
//        guard !searchText.isEmpty else { return all }
//        return all.filter {
//            $0.name.localizedCaseInsensitiveContains(searchText)
//        }
//    }
    
    var filteredProducts: [Product] {
        // Get all products that exist in the current store
        let availableInStore = productStore.products.filter { product in
            productStore.location(for: product, in: selectedStore) != nil
        }

        // If there’s no search text, show all available ones for this store
        guard !searchText.isEmpty else { return availableInStore }

        // Otherwise, return only those that match the search text
        return availableInStore.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }


    /// Finds the section name for a product in the selected store (if mapped)
    private func sectionName(for product: Product) -> String? {
        // Find the location of this product in the selected store
        if let location = productStore.productLocations.first(where: {
            $0.productId == product.id && $0.storeId == selectedStore.id
        }) {
            // Find the matching section name
            if let section = selectedStore.sections.first(where: { $0.id == location.sectionId }) {
                return section.name
            }
        }
        return nil
    }


    /// Build sectioned items: [(StoreSection, [ShoppingListItem])] in store order (with Misc last)
    private func sectionedItems() -> [(StoreSection, [ShoppingListItem])] {
        let store = selectedStore

        // group items by sectionId (String). misc uses nilKey
        var groups: [String: [ShoppingListItem]] = [:]
        let miscKey = "Misc"

        for item in listStore.list.items {
            if let mapping = productStore.productLocations.first(where: { m in
                m.productId == item.product.id && m.storeId == store.id
            }) {
                groups[mapping.sectionId, default: []].append(item)
            } else {
                groups[miscKey, default: []].append(item)
            }
        }

        var result: [(StoreSection, [ShoppingListItem])] = []

        // real sections in order
        for section in store.sections.sorted(by: { $0.order < $1.order }) {
            if let items = groups[section.id], !items.isEmpty {
                let sorted = items.sorted { $0.product.name < $1.product.name }
                result.append((section, sorted))
            }
        }

        // misc last
        if let miscItems = groups[miscKey], !miscItems.isEmpty {
            let miscSection = StoreSection(id: "Misc", name: "Misc", order: Int.max)
            let sorted = miscItems.sorted { $0.product.name < $1.product.name }
            result.append((miscSection, sorted))
        }

        return result
    }
}
