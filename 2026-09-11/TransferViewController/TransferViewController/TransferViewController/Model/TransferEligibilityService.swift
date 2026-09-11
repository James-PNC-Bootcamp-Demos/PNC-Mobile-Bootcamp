//
//  TransferEligibilityService.swift
//  TransferViewController
//
//  Created by user303000 on 9/11/26.
//
import Foundation


// MARK: - TODO 2: TransferEligibilityService

enum TransferError: Error, Equatable {
    case invalidAmount
    case insufficientFunds
}


struct TransferEligibilityService {
    // TODO: implement canTransfer(amount:from:) -> Result<Void, TransferError>
    // covering the same two rules as the BEFORE version above: amount must
    // be greater than zero, and the source account must have sufficient
    // balance.
    
    func canTransfer(amount: Decimal, from: Account) throws -> Result<Void, TransferError>{
        guard amount > 0 else {
            return .failure(TransferError.invalidAmount)
        
        }
        guard from.balance >= amount else {
            return .failure(TransferError.insufficientFunds)
            
        }
        
        return .success(())
    }
}
