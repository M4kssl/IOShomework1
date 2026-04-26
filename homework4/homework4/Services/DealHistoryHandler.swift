//
//  DealHistoryHandler.swift
//  homework4
//
//  Created by Максим  on 25.03.2026.
//

import Foundation

protocol DealHistoryHandlerProtocol {
    func getLastDealForCurrency(withIndetifier id: UUID, in history: [Deal]) -> Deal?
    func getDealResultString(for currency: RandomlyGeneratedCurrency, with action: Action, using dealHistory: [Deal]) -> String
    func getLastNonIgnoreDealForCurrency(withIndetifier id: UUID, in history: [Deal]) -> Deal?
    func getCurrencyHistoryWithotIgnores(for currency: RandomlyGeneratedCurrency, in history: [Deal]) -> [Deal]
    func getActiveHistoryForAPeriod(beginingDate: Date, endDate: Date, histoy: [Deal]) -> [Deal]
    func calculateProfit(forCurrency currency: RandomlyGeneratedCurrency, history: [Deal]) -> Double
}

final class BotHistoryHandler: DealHistoryHandlerProtocol {
    func getDealResultString(for currency: RandomlyGeneratedCurrency, with action: Action, using history: [Deal]) -> String {
        let toValue: Double = currency.quantity * currency.value
        var fromValue: Double = .zero
        var actionToSearch: Action = .ignore
        var income: Double {
            return toValue - fromValue
        }
        
        switch action {
        case .purchase:
            actionToSearch = .sell
        case .sell:
            actionToSearch = .purchase
        case .ignore:
            return ""
        }
        
        if let lastDeal = history.last(where: { $0.action == actionToSearch && $0.currency.name == currency.name }) {
            fromValue = currency.quantity * lastDeal.currency.value
        }
        return "\(action) FROM = \(fromValue.stringWithTwoDecimalPlaces) -> TO = \(toValue.stringWithTwoDecimalPlaces), INCOME = \(income.stringWithTwoDecimalPlaces)\n"
    }
    
    func getLastDealForCurrency(withIndetifier id: UUID, in history: [Deal]) -> Deal? {
        return history.last(where: { $0.currency.id == id })
    }
    
    func getLastNonIgnoreDealForCurrency(withIndetifier id: UUID, in history: [Deal]) -> Deal? {
        return history.last(where: { $0.currency.id == id && $0.action != .ignore })
    }
    
    func getCurrencyHistoryWithotIgnores(for currency: RandomlyGeneratedCurrency, in history: [Deal]) -> [Deal] {
        return history.filter { $0.currency.id == currency.id && $0.action != .ignore }
    }
    
    func getActiveHistoryForAPeriod(beginingDate: Date = .distantPast, endDate: Date = .distantFuture, histoy: [Deal]) -> [Deal] {
        return histoy.filter {
            $0.timestamp >= beginingDate &&
            $0.timestamp <= endDate &&
            $0.action != .ignore
        }
    }
    
    func calculateProfit(forCurrency currency: RandomlyGeneratedCurrency, history: [Deal]) -> Double {
        var profit: Double = 0
        
        for deal in history {
            switch deal.action {
            case .ignore:
                continue
            case .purchase:
                profit -= deal.tradedFor.value * deal.tradedFor.quantity
            case .sell:
                profit += deal.tradedFor.value * deal.tradedFor.quantity
            }
        }
        
        return profit
    }

}
