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

struct Deal {
    let id: UUID
    let action: Action
    let currency: RandomlyGeneratedCurrency
    let result: String?
    let timestamp: Date
}

struct RequestForMarket {
    let action: Action
    let currency: RandomlyGeneratedCurrency
    let quantity: Double
}

protocol BotProtocol {
    var balance: Double { get }
    var decisionsMade: Int { get }
    var currenciesOnHand: [UUID : RandomlyGeneratedCurrency] { get }
    var chosenCurrencies: [RandomlyGeneratedCurrency] { get }
    func decideOnAction(for currency: RandomlyGeneratedCurrency) -> Action
    func formARequestForMarket(toMake action: Action, for currency: RandomlyGeneratedCurrency) -> RequestForMarket
    func processMarketResponse(_ response: MarketResponse)
    func getLastDealForCurrency(withIdentifier id: UUID) -> Deal?
    func getDealHistory() -> [Deal]
    func setCurrencyAsChosen(currency: RandomlyGeneratedCurrency, at index: Int)
    func resetTradingHistory()
}

final class Bot: BotProtocol {
    private var dealHistory: [Deal] = []
    
    private(set) var balance: Double
    private(set) var currenciesOnHand = [UUID : RandomlyGeneratedCurrency]()
    private(set) var decisionsMade: Int = 0
    private(set) var chosenCurrencies = [RandomlyGeneratedCurrency]()
    
    let historyHandler: DealHistoryHandlerProtocol
    
    init(
        currencies: [RandomlyGeneratedCurrency],
        historyHandler: DealHistoryHandlerProtocol,
        amountOfChosenCurrencies: Int
    ) {
        balance = DefaultValues.initialBalance
        self.historyHandler = historyHandler
        
        for currency in currencies {
            currenciesOnHand[currency.id] = RandomlyGeneratedCurrency(
                id: currency.id,
                name: currency.name,
                value: .zero,
                quantity: .zero,
                type: currency.type,
                isChosen: currency.isChosen,
                isFavorited: currency.isFavorited
            )
        }
        for _ in .zero..<amountOfChosenCurrencies {
            chosenCurrencies.append(RandomlyGeneratedCurrency.generatePlaceholderCurrency())
        }
    }
    
    func decideOnAction(for currency: RandomlyGeneratedCurrency) -> Action {
        var decidedAction = Action.ignore
        let key = currency.id
        if let currencyOnHand = currenciesOnHand[key] {
            if currencyOnHand.quantity > .zero, currencyOnHand.value < currency.value {
                decidedAction = .sell
            } else if currencyOnHand.quantity == .zero, currency.value <= balance, currency.value < DefaultValues.maxValueToPurchase {
                decidedAction = .purchase
            }
        }
        decisionsMade += 1
        return decidedAction
    }
    
    func formARequestForMarket(toMake action: Action, for currency:  RandomlyGeneratedCurrency) -> RequestForMarket {
        switch action {
        case .purchase:
            let quantity = Bot.quantityToBuy(for: currency, balance)
            return RequestForMarket(action: action, currency: currency, quantity: quantity)
        case .sell:
            let key = currency.id
            if let currencyOnHand = currenciesOnHand[key] {
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
        let key = response.request.currency.id
        if let currency = currenciesOnHand[key] {
            var newQuantity: Double = .zero
            var newValue: Double = .zero
            switch response.request.action {
            case .purchase:
                newQuantity = currency.quantity + response.request.quantity
                newValue = response.request.currency.value
                balance -= response.request.quantity * response.request.currency.value
            case .sell:
                newQuantity = currency.quantity - response.request.quantity
                balance += response.request.quantity * response.request.currency.value
            default:
                break
            }
            currenciesOnHand[key] = RandomlyGeneratedCurrency(
                id: currency.id,
                name: currency.name,
                value: newValue,
                quantity: newQuantity,
                type: currency.type,
                isChosen: currency.isChosen,
                isFavorited: currency.isFavorited
            )
            registerDeal(for: response.request.currency, action: response.request.action)
        }
    }
    
    func registerDeal(for currency: RandomlyGeneratedCurrency, action: Action) {
        let newDeal = Deal(
            id: UUID(),
            action: action,
            currency: currency,
            result: historyHandler.getDealResult(for: currency, with: action, using: dealHistory),
            timestamp: Date()
        )
        dealHistory.append(newDeal)
    }
    
    func getLastDealForCurrency(withIdentifier id: UUID) -> Deal? {
        return historyHandler.getLastDealForCurrency(withIndetifier: id, in: dealHistory)
    }
    
    func getDealHistory() -> [Deal] {
        return dealHistory
    }
    
    func setCurrencyAsChosen(currency: RandomlyGeneratedCurrency, at index: Int) {
        if currency.id != UUID.empty {
            chosenCurrencies[index] = currency
            synchronizeCurrencies()
        }
    }
    
    func resetTradingHistory() {
        dealHistory.removeAll()
        decisionsMade = 0
    }
}

// MARK: - Private methods
private extension Bot {
    private static func quantityToBuy(for currency: RandomlyGeneratedCurrency, _ balance: Double) -> Double {
        let maximumQuantity = balance/currency.value
        return Double.random(in: 1...maximumQuantity)
    }
    
    func synchronizeCurrencies() {
        let chosenCurrenciesIndetifiers = getChosenCurrenciesIdentifiers()
        for key in currenciesOnHand.keys {
            if let currency = currenciesOnHand[key] {
                let isChosen = chosenCurrenciesIndetifiers.contains(currency.id)
                currenciesOnHand[key] = RandomlyGeneratedCurrency(
                    id: currency.id,
                    name: currency.name,
                    value: currency.value,
                    quantity: currency.quantity,
                    type: currency.type,
                    isChosen: isChosen,
                    isFavorited: currency.isFavorited
                )
            }
        }
    }
    
    func getChosenCurrenciesIdentifiers() -> [UUID] {
        var identifiers = [UUID]()
        for currency in self.chosenCurrencies {
            identifiers.append(currency.id)
        }
        return identifiers
    }

    
}

extension Bot {
    struct DefaultValues {
        static let maxValueToPurchase: Double = 65
        static let initialBalance: Double = 1000
    }
}
