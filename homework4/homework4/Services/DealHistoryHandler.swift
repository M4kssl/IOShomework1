//
//  DealHistoryHandler.swift
//  homework4
//
//  Created by Максим  on 25.03.2026.
//

import Foundation

protocol DealHistoryHandlerProtocol {
    func getLastDealForCurrency(withIndetifier id: UUID, in history: [Deal]) -> Deal?
    func getDealResult(for currency: RandomlyGeneratedCurrency, with action: Action, using dealHistory: [Deal]) -> String
}

final class BotHistoryHandler: DealHistoryHandlerProtocol {
    func getDealResult(for currency: RandomlyGeneratedCurrency, with action: Action, using history: [Deal]) -> String {
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
}
