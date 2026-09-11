//
//  Account.swift
//  TransferViewController
//
//  Created by user303000 on 9/11/26.
//
import Foundation

struct Account: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let maskedNumber: String
    let balance: Decimal
}
