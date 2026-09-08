//
//  ProductList.swift
//  SwiftUIViews_Starter
//
//  Created by user303000 on 9/8/26.
//
import SwiftUI

struct ProductList : View {
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(products) {pro in
                NavigationLink("\(pro.name) - \(pro.color)", value: pro)
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) {
                selectedItem in
                ProductDetails(product: selectedItem)
            }
            .task {
                loadData()
            }
        }
    }
    
    func loadData() {
        products = [
            Product(id: 101, name: "iPhone", productNumber: "12324", color: "White", listPrice: 899),
            Product(id: 102, name: "Android", productNumber: "214332", color: "Blue", listPrice: 329),
            Product(id: 103, name: "Flip Phone", productNumber: "75432", color: "Black", listPrice: 199),
            Product(id: 104, name: "Dumb Phone", productNumber: "12383", color: "Green", listPrice: 299),
            Product(id: 105, name: "Pixel", productNumber: "3214", color: "Gray", listPrice: 139),
            
            
        ]
    }
}

#Preview{
    ContentView()
}
