//
//  ShoppingItem.swift
//  ShoppingList
//
//  Created by David Poole on 9/17/25.
//


import Foundation

struct ShoppingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var isPurchased: Bool = false
    
    init(name: String) {
            self.id = UUID()
            self.name = name
        }
}
