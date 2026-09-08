//
//  Product.swift
//  SwiftUIViews_Starter
//
//  Created by user303000 on 9/8/26.
//
import SwiftUI

@Observable
class Product: Identifiable, Hashable {
    let id: Int
    let name: String
    let productNumber: String
    let color: String
    let listPrice: Double
    
    init(id: Int, name: String, productNumber: String, color: String, listPrice: Double) {
        self.id = id
        self.name = name
        self.productNumber = productNumber
        self.color = color
        self.listPrice = listPrice
    }
    
    // Override == operator to compare products. Returns whether or not ids are equal
    // Used to satisfy hashable/equatable protocol
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
    // Used to satisfy hasher protocol, no idea what it does.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
