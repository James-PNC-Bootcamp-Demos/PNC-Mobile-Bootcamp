//
//  protocol.swift
//  TransferViewController
//
//  Created by user303000 on 9/11/26.
//
import Foundation

// MARK: - TODO 1: AccountsRepository protocol

protocol AccountsRepository {
    // TODO: declare an async throws method to perform a transfer between
    // two accounts for a given amount. Think about what parameters and
    // return type make sense given how it will be called from the
    // ViewModel.
    func transfer(from: Account, to: Account, amount: Decimal) async throws -> Void
}
