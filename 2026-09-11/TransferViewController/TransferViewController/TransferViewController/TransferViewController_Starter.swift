//
//  TransferViewController_Starter.swift
//  PNCMobileApp
//
//  Module 7 — iOS Application Architecture
//  Lab Exercise: Refactor TransferViewController
//
//  SCENARIO
//  The view controller below is a Massive View Controller: it mixes
//  networking, validation, and UI update logic in one class. Your task is
//  to refactor it using the patterns from this module.
//
//  REQUIREMENTS
//  1. Extract a TransferViewModel with ZERO UIKit imports.
//  2. Extract transfer eligibility rules into a TransferEligibilityService.
//  3. Inject an AccountsRepository protocol via the ViewModel's
//     initializer — no singletons.
//  4. The refactored ViewModel must be unit-testable using a fake
//     repository, with no real network call.
//
//  Read through BEFORE_ExistingMassiveViewController below first — really
//  read it, don't skim. Naming what's wrong with it is part of the
//  exercise. Then fill in the TODOs in the scaffolding beneath it.
//

import UIKit

// MARK: - BEFORE: the Massive View Controller (do not edit — refactor FROM this)

class BEFORE_ExistingMassiveViewController: UIViewController {
    var fromAccount: Account!
    var toAccount: Account!
    @IBOutlet weak var amountField: UITextField!

    @IBAction func transferButtonTapped() {
        guard let text = amountField.text,
              let amount = Decimal(string: text) else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        guard amount > 0 else {
            showAlert(message: "Amount must be greater than zero")
            return
        }
        guard fromAccount.balance >= amount else {
            showAlert(message: "Insufficient funds")
            return
        }

        var request = URLRequest(url: URL(string: "https://api.pncmobile.com/transfer")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode([
            "from": fromAccount.id.uuidString,
            "to": toAccount.id.uuidString,
            "amount": "\(amount)",
        ])
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showAlert(message: "Transfer failed. Please try again.")
                } else {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.resume()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Transfer", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TODO 3: TransferViewModel

final class TransferViewModel: AccountsRepository {
    let accountsRepository: AccountsRepository
    let transferEligibilityService: TransferEligibilityService
    
    var onError: Void {
        
    }
    
    var onSuccess: Void {
        
    }
    func transfer(from: Account, to: Account, amount: Decimal) async throws {
        do {
            var hasError = try transferEligibilityService.canTransfer(amount: amount, from: from)
        } catch {
            switch error as? TransferError {
            case .insufficientFunds:
                print("Insufficient funds.")
                return
            case.invalidAmount:
                print("Invalid Amount.")
                return
            case .none:
                print("Unknown Error")
                return
            }
        }
        
        var request = URLRequest(url: URL(string: "https://api.pncmobile.com/transfer")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode([
            "from": from.id.uuidString,
            "to": to.id.uuidString,
            "amount": "\(amount)",
        ])
    }
    
    init(accountsRepository: AccountsRepository, transferEligibilityService: TransferEligibilityService) {
        self.accountsRepository = accountsRepository
        self.transferEligibilityService = transferEligibilityService
    }

}
