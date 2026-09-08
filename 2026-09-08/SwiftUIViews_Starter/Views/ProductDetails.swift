//
//  ProductDetails.swift
//  SwiftUIViews_Starter
//
//  Created by user303000 on 9/8/26.
//

import SwiftUI

struct ProductDetails : View{
    
    var product: Product
    
    var body: some View {
        @Bindable var proBinding = product
        
        VStack {
            Text("Product #\(product.id)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Name : \(product.name)")
                .font(.title)
            
            Text("Number : \(product.productNumber)")
                .font(.title)
            
            Text("Color : \(product.color)")
                .font(.title)
            
            Text("List Price : \(String(format: "$%.2f", product.listPrice))")
                .font(.title)
            
            
        }
    }
}

#Preview {
    ContentView()
}
