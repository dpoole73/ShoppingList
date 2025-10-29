//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var productStore = ProductStore(
//        products: SampleData.products,
//        stores: SampleData.allStores,
//        productLocations: SampleData.productLocations
//    )
//    @StateObject private var listStore = ShoppingListStore(store: SampleData.allStores.first!)
//    @State private var selectedStore: Store = SampleData.allStores.first!
//    @State private var searchText: String = ""
//    @State private var isSearching: Bool = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Store Picker
//                Picker("Select Store", selection: $selectedStore) {
//                    ForEach(productStore.stores) { store in
//                        Text(store.name).tag(store)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//                .padding()
//                .onChange(of: selectedStore) { newStore in
//                    listStore.setStore(newStore)
//                }
//
//                Divider()
//
//                // Search + Dropdown
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Add Product")
//                        .font(.headline)
//
//                    ZStack(alignment: .topLeading) {
//                        VStack(spacing: 0) {
//                            TextField("Search or add product", text: $searchText)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding(.horizontal)
//                                .onChange(of: searchText) { newValue in
//                                    withAnimation {
//                                        isSearching = !newValue.isEmpty
//                                    }
//                                }
//
//                            Spacer()
//                        }
//
//                        if isSearching && !filteredProducts.isEmpty {
//                            VStack(spacing: 0) {
//                                ForEach(filteredProducts, id: \.id) { product in
//                                    Button {
//                                        listStore.addProduct(product)
//                                        searchText = ""
//                                        withAnimation {
//                                            isSearching = false
//                                        }
//                                    } label: {
//                                        HStack {
//                                            Text(product.name)
//                                                .foregroundColor(.primary)
//                                            Spacer()
//                                            if let sectionName = sectionName(for: product) {
//                                                Text(sectionName)
//                                                    .foregroundColor(.secondary)
//                                                    .italic()
//                                            }
//                                        }
//                                        .padding(.horizontal)
//                                        .padding(.vertical, 8)
//                                    }
//                                    Divider()
//                                }
//                            }
//                            .background(.ultraThinMaterial)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                            .shadow(radius: 5)
//                            .transition(.opacity.combined(with: .move(edge: .top)))
//                            .zIndex(1)
//                        }
//                    }
//                }
//                .padding(.bottom)
//
//                // Sectioned Shopping List
//                List {
//                    ForEach(sectionedItems(), id: \.0.id) { section, items in
//                        Section(header: Text(section.name)) {
//                            ForEach(items, id: \.id) { product in
//                                HStack {
//                                    Text(product.name)
//                                    Spacer()
//                                    if let sectionName = sectionName(for: product) {
//                                        Text(sectionName)
//                                            .foregroundColor(.secondary)
//                                            .italic()
//                                    }
//                                }
//                            }
//                            .onDelete { offsets in
//                                listStore.removeItems(at: offsets, in: items)
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Shopping List")
//            .onAppear {
//                listStore.setStore(selectedStore)
//            }
//        }
//    }
//
//    // MARK: - Helper Functions
//
//    private var filteredProducts: [Product] {
//        if searchText.isEmpty { return [] }
//        return productStore.products.filter {
//            $0.name.lowercased().contains(searchText.lowercased())
//        }
//    }
//
//    private func sectionName(for product: Product) -> String? {
//        // find the mapping for this product in the selected store
//        // step-by-step to avoid long closure expressions
//        if let mapping = productStore.productLocations.first(where: { mapping in
//            mapping.product.id == product.id && mapping.storeId == selectedStore.id
//        }) {
//            // find the corresponding section in the selectedStore
//            if let section = selectedStore.sections.first(where: { $0.id == mapping.sectionId }) {
//                return section.name
//            }
//        }
//        return nil
//    }
//
//    private func sectionedItems() -> [(StoreSection, [ShoppingListItem])] {
//            let store = selectedStore
//
//            // group items by section
//            var dict: [UUID: [ShoppingListItem]] = [:] // key = sectionId
//
//            for item in listStore.list.items {
//                // find productLocation for this product in the current store
//                if let mapping = productStore.productLocations.first(where: { mapping in
//                    mapping.product.id == item.product.id && mapping.storeId == store.id
//                }) {
//                    dict[mapping.sectionId, default: []].append(item)
//                } else {
//                    // use a special misc section id (we'll map to a StoreSection with order = Int.max later)
//                    dict[UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, default: []].append(item)
//                }
//            }
//
//            // build the result array ordered by store.sections order
//            var result: [(StoreSection, [ShoppingListItem])] = []
//
//            // include real sections in order
//            for section in store.sections.sorted(by: { $0.order < $1.order }) {
//                if let items = dict[section.id], !items.isEmpty {
//                    // sort items alphabetically by product name within a section
//                    let sorted = items.sorted { $0.product.name < $1.product.name }
//                    result.append((section, sorted))
//                }
//            }
//
//            // handle misc items (if any)
//            let miscKey = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
//            if let miscItems = dict[miscKey], !miscItems.isEmpty {
//                let miscSection = StoreSection(id: UUID(), name: "Misc", order: Int.max)
//                let sortedMisc = miscItems.sorted { $0.product.name < $1.product.name }
//                result.append((miscSection, sortedMisc))
//            }
//
//            return result
//        }
//}
