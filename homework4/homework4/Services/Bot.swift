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
    let tradedFor: RandomlyGeneratedCurrency
    let result: String?
    let timestamp: Date
    let coversionRate: Double
}

struct RequestForMarket {
    let action: Action
    let currency: RandomlyGeneratedCurrency
    let quantity: Double
}

protocol BotProtocol {
    var name: String { get }
    var chosenCurrencies: [RandomlyGeneratedCurrency] { get }
    var profit: Double { get }
    
    func runOperation()
    func getLastDealForCurrency(withIdentifier id: UUID) -> Deal?
    func getDealHistory() -> [Deal]
    func setCurrencyAsChosen(currency: RandomlyGeneratedCurrency, at index: Int)
    func resetTradingHistory()
    func calculateProfitForAPeriod(startDate: Date, endDate: Date) -> Double
    func updateChosenCurrencies(from currencies: [UUID : RandomlyGeneratedCurrency])
}

final class Bot: BotProtocol {
    private var dealHistory: [Deal] = []
    
    private(set) var decisionsMade: Int = 0
    private(set) var chosenCurrencies = [RandomlyGeneratedCurrency]()
    private(set) var name: String = ""
    private(set) var profit: Double = 0
    
    let wallet: WalletProtocol
    let walletHandler: WalletHandlerProtocol
    let historyHandler: DealHistoryHandlerProtocol
    
    init(
        currencies: [RandomlyGeneratedCurrency],
        historyHandler: DealHistoryHandlerProtocol,
        wallet: WalletProtocol,
        walletHandler: WalletHandlerProtocol,
        amountOfChosenCurrencies: Int,
        namePostfix: String
    ) {
        self.historyHandler = historyHandler
        var allCurrencies = currencies
        for _ in .zero..<amountOfChosenCurrencies {
            let randomIndex = Int.random(in: .zero..<allCurrencies.endIndex)
            chosenCurrencies.append(allCurrencies[randomIndex])
            allCurrencies.remove(at: randomIndex)
        }
        name = "\(chosenCurrencies[0].name)_\(chosenCurrencies[1].name)_\(namePostfix)"
        self.wallet = wallet
        self.walletHandler = walletHandler
    }
    
    func runOperation() {
        let action = decideOnAction()
        makeAction(action: action)
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
        }
    }
    
    func updateChosenCurrencies(from currencies: [UUID : RandomlyGeneratedCurrency]) {
        for index in chosenCurrencies.indices {
            if let currentCurrency = currencies[chosenCurrencies[index].id] {
                chosenCurrencies[index] = currentCurrency
            }
        }
    }
    
    func resetTradingHistory() {
        dealHistory.removeAll()
        decisionsMade = .zero
    }
    
    func calculateProfitForAPeriod(startDate: Date = .distantPast, endDate: Date = .distantFuture) -> Double {
        let activeHistory = historyHandler.getActiveHistoryForAPeriod(
            beginingDate: startDate,
            endDate: endDate,
            histoy: dealHistory
        )
        
        return historyHandler.calculateProfit(forCurrency: chosenCurrencies[0], history: activeHistory)
    }
}

// MARK: - Private Methods
private extension Bot {
    func decideBasedOnCurrentValues() -> Action {
        let firstChosenCurrency = chosenCurrencies[0]
        let secondChosenCurrency = chosenCurrencies[1]
        
        let currentConversionRate = Market.conversionRate(fromCurrency: firstChosenCurrency, toCurrency: secondChosenCurrency)
        
        if currentConversionRate > 1.2, firstChosenCurrency.value > DefaultValues.minValueToSell{
            return .sell
        } else if currentConversionRate < 0.8, firstChosenCurrency.value < DefaultValues.maxValueToPurchase {
            return .purchase
        } else {
            return .ignore
        }
    }
    
    func decideBasedOnHistory(firstCurrencyLastDeal: Deal) -> Action {
        let firstChosenCurrency = chosenCurrencies[0]
        let secondChosenCurrency = chosenCurrencies[1]
        
        switch firstCurrencyLastDeal.action {
        case .purchase:
            let currentConversionRate = Market.conversionRate(fromCurrency: firstChosenCurrency, toCurrency: secondChosenCurrency)
            if currentConversionRate > firstCurrencyLastDeal.coversionRate,
               firstChosenCurrency.value > firstCurrencyLastDeal.currency.value,
               firstChosenCurrency.value > DefaultValues.minValueToSell,
               currentConversionRate > 1.2 {
                return .sell
            } else {
                return .ignore
            }
        case .sell:
            let currentConversionRate = Market.conversionRate(fromCurrency: firstChosenCurrency, toCurrency: secondChosenCurrency)
            if currentConversionRate < firstCurrencyLastDeal.coversionRate,
                firstChosenCurrency.value < firstCurrencyLastDeal.currency.value,
                firstChosenCurrency.value < DefaultValues.maxValueToPurchase,
               currentConversionRate < 0.8 {
                return .purchase
            } else {
                return .ignore
            }
        case .ignore:
           return decideBasedOnCurrentValues()
        }
    }
    
    func getChosenCurrenciesIdentifiers() -> [UUID] {
        var identifiers = [UUID]()
        for currency in self.chosenCurrencies {
            identifiers.append(currency.id)
        }
        return identifiers
    }
   
    func registerDeal(for currency: RandomlyGeneratedCurrency, action: Action, tradedFor: RandomlyGeneratedCurrency) {
        let newDeal = Deal(
            id: UUID(),
            action: action,
            currency: currency,
            tradedFor: tradedFor,
            result: historyHandler.getDealResultString(for: currency, with: action, using: dealHistory),
            timestamp: .now,
            coversionRate: Market.conversionRate(fromCurrency: currency, toCurrency: tradedFor)
        )
        dealHistory.append(newDeal)
    }
    
    func decideOnAction() -> Action {
        if dealHistory.isEmpty {
            return decideBasedOnCurrentValues()
        } else {
            let activeHistory = historyHandler.getCurrencyHistoryWithotIgnores(for: chosenCurrencies[0], in: dealHistory)
            let firstCurrencyLastDeal = historyHandler.getLastDealForCurrency(withIndetifier: chosenCurrencies[0].id, in: activeHistory)
            if let firstCurrencyLastDeal {
                return decideBasedOnHistory(firstCurrencyLastDeal: firstCurrencyLastDeal)
            } else {
                return decideBasedOnCurrentValues()
            }
        }
    }
    
    func makeAction(action: Action) {
        let firstChosenCurrency = chosenCurrencies[0]
        let secondChosenCurrency = chosenCurrencies[1]
            
        do {
            var firstCurrencyForDealQuantity: Double = 0
            var secondCurrencyForDealQuantity: Double = 0
            switch action {
            case .purchase:
                let quantityBought = try walletHandler.calcultateQuantityAndPurchaseIfAbleTo(
                    currencyToBuy: firstChosenCurrency,
                    currencyToSell: secondChosenCurrency,
                    quantityToSell: DefaultValues.quanityToSellPerDeal,
                    wallet: wallet
                )
                firstCurrencyForDealQuantity = quantityBought
                secondCurrencyForDealQuantity = DefaultValues.quanityToSellPerDeal
                
            case.sell:
                let quantityBought = try walletHandler.calcultateQuantityAndPurchaseIfAbleTo(
                    currencyToBuy: secondChosenCurrency,
                    currencyToSell: firstChosenCurrency,
                    quantityToSell: DefaultValues.quanityToSellPerDeal,
                    wallet: wallet
                )
                firstCurrencyForDealQuantity = DefaultValues.quanityToSellPerDeal
                secondCurrencyForDealQuantity = quantityBought
            case .ignore:
                break
            }
            
            let firstCurrencyForDeal = RandomlyGeneratedCurrency.changeQuanityForCurrency(
                currency: firstChosenCurrency,
                newQuantity: firstCurrencyForDealQuantity
            )
            
            let secondCurrencyForDeal = RandomlyGeneratedCurrency.changeQuanityForCurrency(
                currency: secondChosenCurrency,
                newQuantity: secondCurrencyForDealQuantity
            )
            
            registerDeal(for: firstCurrencyForDeal, action: action, tradedFor:  secondCurrencyForDeal)
        } catch {
            registerDeal(for: firstChosenCurrency, action: .ignore, tradedFor:  secondChosenCurrency)
        }
    }
}

private extension Bot {
    enum DefaultValues {
        static let maxValueToPurchase: Double = 50
        static let quanityToSellPerDeal: Double = 10
        static let minValueToSell: Double = 60
    }
}
