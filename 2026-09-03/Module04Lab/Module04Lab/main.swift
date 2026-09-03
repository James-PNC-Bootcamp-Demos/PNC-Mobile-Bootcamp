
// ============================================================
// MODULE 4: Swift Programming Fundamentals
// LAB — PNC Banking Domain Model
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// OVERVIEW
// You are building the Swift data model layer for the PNC Mobile
// Banking application. This layer will be carried forward into
// Modules 6, 7, and 8 as the foundation of the real application.
//
// Every type you define here uses the Swift features from all
// three days of this module. Take time to read the full spec
// before writing any code.
//
// ESTIMATED TIME: 90–120 minutes
//
// ============================================================
// LAB SPEC
// ============================================================
//
// You will build five interconnected Swift types:
//
//   1. TransactionType enum
//   2. TransactionStatus enum
//   3. Transaction struct
//   4. Account class
//   5. AccountAnalytics struct
//
// And three protocols:
//
//   A. Summarizable       — any type that can produce a summary string
//   B. AccountOperations  — deposit, withdraw, transfer
//   C. AnalyticsProvider  — compute basic financial metrics
//
// The lab ends with an error handling system and a generic
// result reporting function that ties everything together.
//
// Read each section completely before implementing it.
// ============================================================

import Foundation


// ============================================================
// SECTION 1: Enumerations
// ============================================================

// TODO 1A: TransactionType
// Conform to: String, CaseIterable, Codable
// Cases:     credit, debit, transfer, fee
// Add computed property: isExpense: Bool
//   → true for .debit and .fee, false otherwise
enum TransactionType : String, CaseIterable, Codable {
    case credit
    case debit
    case transfer
    case fee
    
    var isExpense : Bool {
        switch self {
        case .credit, .transfer:
            return false
        case .debit, .fee:
            return true
        }
    }
}

// TODO 1B: TransactionStatus
// Conform to: String, Codable
// Cases:     pending, completed, failed, cancelled
// Add computed property: isTerminal: Bool
//   → true for .completed, .failed, .cancelled
//   → false for .pending (can still change)
enum TransactionStatus : String, Codable {
    case pending
    case completed
    case failed
    case cancelled
    
    var isTerminal: Bool {
        switch self {
        case .pending:
            return false
        case .cancelled, .failed, .completed:
            return true
        }
    }
}

// ============================================================
// SECTION 2: Transaction Struct
// ============================================================

// TODO 2: Define struct Transaction conforming to:
//   Identifiable, Codable, Equatable, Hashable, Summarizable (see Section 4A)
//
// Stored properties:
//   id: String                (unique identifier, default to UUID().uuidString)
//   date: Date
//   amount: Double            (always positive — type determines direction)
//   description: String
//   type: TransactionType
//   status: TransactionStatus (default: .completed)
//   category: String?
//   merchantName: String?
//
// Computed properties:
//   formattedAmount: String
//     → "-$X.XX" for expenses (type.isExpense == true)
//     → "+$X.XX" for income/credit
//
//   formattedDate: String
//     → Use DateFormatter with dateStyle: .medium, timeStyle: .short
//
//   resolvedCategory: String
//     → Returns category if non-nil, "Uncategorized" otherwise
//
// Custom initializer (all params except id, status, category, merchantName
// should be required; the rest should have defaults):
//   init(date:amount:description:type:status:category:merchantName:)
struct Transaction : Identifiable, Codable, Equatable, Hashable, Summarizable {
    var id: String = UUID().uuidString
    let date: Date
    let amount: Double
    var description: String
    let type: TransactionType
    var status: TransactionStatus = .completed
    let category: String?
    let merchantName: String?
    
    var formattedAmount: String {
        if type.isExpense {
            return String(format: "-$%.2f", amount)
        } else {
            return String(format: "+$%.2f", amount)
        }
    }
    
    var formattedDate: String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    
    var resolvedCategory: String {
        guard let safeCategory = category else {
            return "Uncategorized"
        }
        
        return safeCategory
    }
    
    var summary : String {
        " \(formattedDate): \(formattedAmount) - \(description)"
    }
    init(date: Date, amount: Double, description: String, type: TransactionType, status: TransactionStatus){
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = nil
        self.merchantName = nil
    }

}

// ============================================================
// SECTION 3: Account Class
// ============================================================

// TODO 3A: Define protocol AccountOperations (see Section 4B)
// before defining Account, because Account will conform to it.
// (Define the protocol in Section 4B, then add conformance to Account here)

// TODO 3B: Define class BankAccount conforming to:
//   Identifiable, AccountOperations, Summarizable
//
// Stored properties:
//   id: String
//   accountNumber: String
//   accountType: String          (e.g., "CHECKING", "SAVINGS")
//   nickname: String?
//   var balance: Double
//   var availableBalance: Double
//   let currency: String         (default "USD")
//   let isActive: Bool           (default true)
//   var transactions: [Transaction]
//
// Computed properties:
//   displayName: String          → nickname if non-nil, else accountType.capitalized
//   maskedAccountNumber: String  → "****" + last 4 digits
//   formattedBalance: String     → "$X.XX"
//   recentTransactions: [Transaction]  → last 5, sorted by date descending
//   pendingCount: Int            → count of transactions with status .pending
//
// Designated initializer:
//   init(id:accountNumber:accountType:nickname:initialBalance:currency:isActive:)
//
// Implement AccountOperations (see Section 4B for the protocol requirements).
// Use the AccountError enum from Section 4C.
//
// Also add:
//   func addTransaction(_ transaction: Transaction)
//     → appends to transactions AND updates balance:
//       if transaction.type.isExpense: balance -= transaction.amount
//       else:                          balance += transaction.amount
//       Update availableBalance to match balance.

class BankAccount : Identifiable, AccountOperations, Summarizable {
    func deposit(amount: Double) throws {
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        balance += amount
    }
    
    func addTransaction(_ transaction: Transaction) {
        if transaction.type.isExpense{
            balance -= transaction.amount
        } else{
            balance += transaction.amount
        }
        
        self.transactions.append(transaction)
        availableBalance = balance
    }
    
    func withdraw(amount: Double) throws {
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        guard amount <= availableBalance else {
            throw AccountOperationsError.insufficientFunds(available: availableBalance, required: amount)
        }
        
        balance -= amount
    }
    
    func transfer(amount: Double, to destination: BankAccount) throws {
        guard destination.isActive else {
            throw AccountOperationsError.accountInactive
        }
        
        guard destination.id != self.id else {
            throw AccountOperationsError.transferToSameAccount
        }
        
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        guard amount <= availableBalance else {
            throw AccountOperationsError.insufficientFunds(available: availableBalance, required: amount)
        }
        
        balance -= amount
    }
    let id: String
    let accountNumber: String
    let accountType: String
    let nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String
    var isActive: Bool = true
    var transactions: [Transaction]
    
    var displayName: String {
        if let nick = nickname {
            return nick
        } else{
            return "\(accountType.capitalized)"
        }
    }
    var maskedAccountNumber: String {
        return "****\(accountNumber.suffix(4))"
    }
    
    var formattedBalance: String {
        return String(format: "%.2f", balance)
    }
    
    // potential logic error here
    var recentTransactions: [Transaction] {
        return transactions.sorted(by: { $0.date > $1.date }).prefix(5).map(\.self)
    }
    
    var pendingCount: Int {
        return transactions.count(where: { $0.status == .pending })
    }
    
    var summary : String {
        return "The account at id \(id) has a balance of \(formattedBalance)."
    }
    init(id: String, accountNumber: String, accountType: String, nickname: String?, initialBalance: Double, currency: String, isActive: Bool){
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = initialBalance
        self.availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
        self.transactions = []
    }
}
    // ============================================================
    // SECTION 4: Protocols
    // ============================================================
    
    // TODO 4A: Summarizable protocol
    //   Required: var summary: String { get }
    //   Default implementation via extension: func printSummary() — prints summary
    protocol Summarizable {
        var summary: String { get }
    }
    
    extension Summarizable {
        func printSummary() {
            print(summary)
        }
    }
    
    // TODO 4B: AccountOperations protocol
    //   func deposit(amount: Double) throws
    //   func withdraw(amount: Double) throws
    //   func transfer(amount: Double, to destination: BankAccount) throws
    //
    // These methods throw AccountOperationsError (define in Section 4C).
    protocol AccountOperations {
        func deposit(amount: Double) throws
        func withdraw(amount: Double) throws
        func transfer(amount: Double, to destination: BankAccount) throws
    }
    
    // TODO 4C: AccountOperationsError enum conforming to LocalizedError
    // Cases:
    //   invalidAmount
    //   insufficientFunds(available: Double, required: Double)
    //   accountInactive
    //   transferToSameAccount
    //   dailyLimitExceeded(limit: Double)
    //
    // Each case should have a meaningful errorDescription.
enum AccountOperationsError : LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)
    
    var errorDescription: String {
        switch self {
        case .invalidAmount:
            return "The amount you entered is not valid."
        case .insufficientFunds(available: let available, required: let required):
            return "Insufficient funds. Available: \(available), Required: \(required)."
        case .accountInactive:
            return "This account is currently inactive."
        case .transferToSameAccount:
            return "You cannot transfer to your own account."
        case .dailyLimitExceeded(limit: let limit):
            return "Daily limit of \(limit) has been exceeded."
        }
    }
}
    
    // ============================================================
    // SECTION 5: Analytics
    // ============================================================
    
    // TODO 5A: AnalyticsProvider protocol
    //   var totalCredits: Double { get }
    //   var totalDebits: Double { get }
    //   var netFlow: Double { get }         // credits - debits
    //   var largestTransaction: Transaction? { get }
    //   func monthlyTotal(month: Int, year: Int) -> Double
    //   func transactionsByCategory() -> [String: [Transaction]]
protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }
    var largestTransaction: Transaction? { get }
    
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}
    
    // TODO 5B: AccountAnalytics struct
    // Stored property: transactions: [Transaction]
    // Conform to AnalyticsProvider.
    // Implement each requirement.
    //
    // Tips:
    //   totalCredits: use .filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
    //   transactionsByCategory: group by resolvedCategory using a Dictionary
    //     (hint: use Dictionary(grouping:by:))
    //   monthlyTotal: filter by Calendar.current month/year components and sum expense amounts

struct AccountAnalytics : AnalyticsProvider {
    
    var account: BankAccount
    
    var totalCredits: Double {
        return account.transactions.filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }

    var totalDebits: Double {
        return account.transactions.filter({ $0.type == .debit }).reduce(0) {$0 + $1.amount }
    }
    
    var netFlow: Double {
        return totalCredits - totalDebits
    }
    
    var largestTransaction: Transaction? {
        guard account.transactions.isEmpty == false else { return nil }
        
        return account.transactions.max(by: { $0.amount < $1.amount })
    }
    
    func monthlyTotal(month: Int, year: Int) -> Double {
        return transactions.filter { $0.formattedDate.contains("\(month) \(year)") }.reduce(0) {$0 + $1.amount}
    }
    
    func transactionsByCategory() -> [String : [Transaction]] {
        return transactions.count == 0 ? [:] : Dictionary(grouping: transactions, by: \.resolvedCategory)
    }
    
    var transactions: [Transaction]
    
    init(account: BankAccount) {
        self.account = account
        self.transactions = []
    }
    
}
    
    // ============================================================
    // SECTION 6: Generic Result Reporter
    // ============================================================
    
    // TODO 6: Write a generic function:
    //   func reportResults<T: Summarizable>(_ items: [T], title: String)
    //
    // It should:
    //   1. Print a header line: "=== [title] ==="
    //   2. Print the item count: "[N] items"
    //   3. Call printSummary() on each item
    //   4. Print a footer: "=== End of [title] ==="
    //
    // The function must work for any type conforming to Summarizable —
    // including both Transaction and BankAccount.
func reportResults<T: Summarizable>(_ items: [T], title: String) {
    print("===\(title)===")
    print("\(items.count) items")
    for item in items {
        item.printSummary()
    }
    print("=== End of \(title) ===")
}
    
    // ============================================================
    // SECTION 7: INTEGRATION TEST — Tie it all together
    // ============================================================
    
    // TODO 7: Write a function named runlabDemo() that does the following:
    
    // 7A: Create at least two BankAccount instances:
    //   - A checking account with $3,500 initial balance
    //   - A savings account with $12,000 initial balance
    
    // 7B: Create at least five Transaction instances across different types
    //   and add them to the checking account using addTransaction(_:)
    //   Include: one credit, two debits, one fee, one transfer
    //   Verify the balance updates correctly after each addition.
    
    // 7C: Demonstrate error handling:
    //   - Try to withdraw more than the available balance → catch insufficientFunds
    //   - Try to deposit a negative amount → catch invalidAmount
    //   - Try to transfer to the same account → catch transferToSameAccount
    //   Print the localized error description for each caught error.
    
    // 7D: Create an AccountAnalytics instance with the checking account's transactions.
    //   Print:
    //   - Total credits
    //   - Total debits
    //   - Net flow
    //   - The description and amount of the largest transaction
    //   - The transactions grouped by category (print each category and count)
    
    // 7E: Call reportResults with the checking account's transactions, title: "Checking Transactions"
    //   Call reportResults with [checkingAccount, savingsAccount], title: "All Accounts"
    
    // 7F: Demonstrate value vs. reference semantics:
    //   Copy one Transaction (struct) into a new variable. Modify the copy's description.
    //   Show the original is unchanged.
    //   Assign the checking account (class) to a new variable. Deposit $100 through the alias.
    //   Show both variables reflect the updated balance.
func runlabDemo() {
    let bankAccountOne = BankAccount(id: "1", accountNumber: "32513124", accountType: "Checking", nickname: nil, initialBalance: 3_500, currency: "USD", isActive: true)
    
    let bankAccountTwo = BankAccount(id: "2", accountNumber: "123423651", accountType: "Savings", nickname: "Backup Fund", initialBalance: 12_500, currency: "USD", isActive: true)
    
    let transaction = Transaction(
        date: Date(),
        amount: 25.50,
        description: "Grilled Sandwich Refund",
        type: .credit,
        status: .completed
    )
    
    let transaction1 = Transaction(
        date: Date(),
        amount: 25.50,
        description: "Lunch",
        type: .debit,
        status: .completed
    )
    
    let transaction2 = Transaction(
        date: Date(),
        amount: 258.50,
        description: "Groceries",
        type: .debit,
        status: .completed
    )
    
    let transaction3 = Transaction(
        date: Date(),
        amount: 5.50,
        description: "Interest due",
        type: .fee,
        status: .completed
    )
    
    let transaction4 = Transaction(
        date: Date(),
        amount: 25.50,
        description: "Rent Portion",
        type: .transfer,
        status: .completed
    )
    
    bankAccountOne.addTransaction(transaction)
    bankAccountOne.addTransaction(transaction1)
    bankAccountOne.addTransaction(transaction2)
    bankAccountOne.addTransaction(transaction3)
    bankAccountOne.addTransaction(transaction4)
    
    
    do {
        try bankAccountOne.withdraw(amount: 10000)
    } catch let error as AccountOperationsError {
        print(error.errorDescription)
    } catch {
        print("Unknown Error \(error)")
    }

    do {
        try bankAccountOne.deposit(amount: -53)
    } catch let error as AccountOperationsError {
        print(error.errorDescription)
    } catch {
        print("Unknown Error \(error)")
    }

    do {
        try bankAccountOne.transfer(amount: 100, to: bankAccountOne)
    } catch let error as AccountOperationsError {
        print(error.errorDescription)
    } catch {
        print("Unknown Error \(error)")
    }
    
    let accountAnalytics =	 AccountAnalytics (account: bankAccountOne)
    
    print(accountAnalytics.totalCredits)
    print(accountAnalytics.totalDebits)
    print(accountAnalytics.netFlow)
    
    if let trans = accountAnalytics.largestTransaction {
        print("Largest Transaction: \(trans.description) Amount: \(trans.amount)")
    }
    
    print(accountAnalytics.transactionsByCategory)
    
    
    reportResults(bankAccountOne.transactions, title: "Checking Transactions")
    reportResults([bankAccountOne, bankAccountTwo], title: "All Accounts")
    
    print(transaction1.description)
    var transaction5 = transaction1
    
    transaction5.description = "new description"
    print(transaction1.description)
    
    print(bankAccountOne.balance)
    let bankAccountThree = bankAccountOne		
    bankAccountThree.balance = 2000
    print(bankAccountOne.balance)
}
    // TODO: Call runlabDemo() at the bottom of the file.
    runlabDemo()
    
    // ============================================================
    // END OF LAB
    // ============================================================
    //
    // SELF-ASSESSMENT CHECKLIST
    // Before submitting, verify:
    //   [X] All five types compile without warnings
    //   [X] runlabDemo() runs to completion with no crashes
    //   [X] Each error case in 7C is handled and prints a clear message
    //   [X] Struct copy semantics are correctly demonstrated in 7F
    //   [X] Class reference semantics are correctly demonstrated in 7F
    //   [X] reportResults works for both Transaction and BankAccount
    //   [X] Analytics produce correct totals matching your transactions
    // ============================================================
