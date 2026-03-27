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
    let action: Action
    let currency: Currency
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
}

final class Bot: BotProtocol {
    private let maxValueToPurchase: Double = 65
    private let logger: LoggerProtocol
    private var dealHistory: [Deal] = []
    
    private(set) var balance: Double
    private(set) var currenciesOnHand: [Currency] = []
    private(set) var decisionsMade: Int = 0
    
    init (logger: LoggerProtocol) {
        balance = 1000
        for currency in Currency.CurrencyName.allCases {
            currenciesOnHand.append(Currency(name: currency, quantity: 0, value: 0))
        }
        self.logger = logger
    }
    
    func decideOnAction(for currency: Currency) -> Action {
        var decidedAction = Action.ignore
        if let currencyOnHand = currenciesOnHand.first(where: { $0.name == currency.name }) {
            if currencyOnHand.quantity > 0, currencyOnHand.value < currency.value {
                decidedAction = .sell
            } else if currencyOnHand.quantity == 0, currency.value <= balance, currency.value < maxValueToPurchase {
                decidedAction = .purchase
            }
        }
        logger.logAction(decidedAction, for: currency)
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
                return RequestForMarket(action: .ignore, currency: currency, quantity: 0)
            }
        default:
            return RequestForMarket(action: .ignore, currency: currency, quantity: 0)
        }
    }
    
    func processMarketResponse(_ response: MarketResponse) {
        guard response.status == .success else {
            logger.logMarketResponse(response)
            return
        }
        if let index = currenciesOnHand.firstIndex(where: { $0.name == response.request.currency.name }) {
            var newQuantity: Double = 0
            var newValue: Double = 0
            switch response.request.action{
            case .purchase:
                newQuantity = currenciesOnHand[index].quantity + response.request.quantity
                newValue = response.request.currency.value
                balance -= response.request.quantity * response.request.currency.value
            case .sell:
                newQuantity = currenciesOnHand[index].quantity - response.request.quantity
                balance += response.request.quantity * response.request.currency.value
            default:
                return
            }
            currenciesOnHand[index] = Currency(name: response.request.currency.name, quantity: newQuantity, value: newValue)
            registerDeal(for: response.request.currency, action: response.request.action)
            logger.logLastDealResult(dealHistory)
        }
    }
    
    func registerDeal(for currency: Currency, action: Action) {
        dealHistory.append(Deal(action: action, currency: currency, timestamp: Date()))
    }
    
}

// MARK: - Private Methods
private extension Bot {
    private static func quantityToBuy(for currency: Currency, _ balance: Double) -> Double {
        let maximumQuantity = balance/currency.value
        return Double.random(in: 1...maximumQuantity)
    }
}
