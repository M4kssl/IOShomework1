//
//  Bot.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import Foundation

enum Action {
    case ignore
    case purchase
    case sell
}

struct Deal: Equatable {
    let id: UUID
    let action: Action
    let currency: Currency
    let result: String?
    let timestamp: Date
}

struct RequestForMarket {
    let action: Action
    let currency: Currency
    let quantity: Double
}

protocol BotProtocol {
    var balance: Double { get }
    var decisionsMade: Int { get }
    var currenciesOnHand: [Currency] { get }
    func decideOnAction(for currency: Currency) -> Action
    func formARequestForMarket(toMake action: Action, for currency: Currency) -> RequestForMarket
    func processMarketResponse(_ response: MarketResponse)
    func getLastDealForCurrency(withName currencyName: Currency.CurrencyName) -> Deal?
    func getDealHistory() -> [Deal]
}

final class Bot: BotProtocol {
    private var dealHistory: [Deal] = []
    
    private(set) var balance: Double
    private(set) var currenciesOnHand: [Currency] = []
    private(set) var decisionsMade: Int = 0
    
    let historyHandler: DealHistoryHandlerProtocol
    
    init (historyhandler: DealHistoryHandlerProtocol) {
        balance = DefaultValues.initialBalance
        for currency in Currency.CurrencyName.allCases {
            currenciesOnHand.append(Currency(name: currency, quantity: .zero, value: .zero))
        }
        self.historyHandler = historyhandler
    }
    
    func decideOnAction(for currency: Currency) -> Action {
        var decidedAction = Action.ignore
        if let currencyOnHand = currenciesOnHand.first(where: { $0.name == currency.name }) {
            if currencyOnHand.quantity > .zero, currencyOnHand.value < currency.value {
                decidedAction = .sell
            } else if currencyOnHand.quantity == .zero, currency.value <= balance, currency.value < DefaultValues.maxValueToPurchase {
                decidedAction = .purchase
            }
        }
        decisionsMade += 1
        return decidedAction
    }
    
    func formARequestForMarket(toMake action: Action, for currency:  Currency) -> RequestForMarket {
        switch action {
        case .purchase:
            let quantity = Bot.quantityToBuy(for: currency, balance)
            return RequestForMarket(action: action, currency: currency, quantity: quantity)
        case .sell:
            if let currencyOnHand = currenciesOnHand.first(where: { $0.name == currency.name }) {
                return RequestForMarket(action: action, currency: currency, quantity: currencyOnHand.quantity)
            } else {
                return RequestForMarket(action: .ignore, currency: currency, quantity: .zero)
            }
        default:
            return RequestForMarket(action: .ignore, currency: currency, quantity: .zero)
        }
    }
    
    func processMarketResponse(_ response: MarketResponse) {
        guard response.status == .success else {
            return
        }
        if let index = currenciesOnHand.firstIndex(where: { $0.name == response.request.currency.name }) {
            var newQuantity: Double = .zero
            var newValue: Double = .zero
            switch response.request.action {
            case .purchase:
                newQuantity = currenciesOnHand[index].quantity + response.request.quantity
                newValue = response.request.currency.value
                balance -= response.request.quantity * response.request.currency.value
            case .sell:
                newQuantity = currenciesOnHand[index].quantity - response.request.quantity
                balance += response.request.quantity * response.request.currency.value
            default:
                break
            }
            currenciesOnHand[index] = Currency(name: response.request.currency.name, quantity: newQuantity, value: newValue)
            registerDeal(for: response.request.currency, action: response.request.action)
        }
    }
    
    func registerDeal(for currency: Currency, action: Action) {
        let newDeal = Deal(
            id: UUID(),
            action: action,
            currency: currency,
            result: historyHandler.getDealResult(for: currency, with: action, using: dealHistory),
            timestamp: Date()
        )
        dealHistory.append(newDeal)
    }
    
    func getLastDealForCurrency(withName currencyName: Currency.CurrencyName) -> Deal? {
        return historyHandler.getLastDealForCurrency(withName: currencyName, in: dealHistory)
    }
    
    func getDealHistory() -> [Deal] {
        return dealHistory
    }
}

// MARK: - Private methods
private extension Bot {
    private static func quantityToBuy(for currency: Currency, _ balance: Double) -> Double {
        let maximumQuantity = balance/currency.value
        return Double.random(in: 1...maximumQuantity)
    }
}

extension Bot {
    struct DefaultValues {
        static let maxValueToPurchase: Double = 65
        static let initialBalance: Double = 1000
    }
}
