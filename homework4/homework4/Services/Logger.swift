//
//  Logger.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import UIKit

protocol LoggerProtocol {
    func logAction(_ action: Action, for currency: Currency)
    func logLastDealResult(_ dealHistory: [Deal])
    func logMarketResponse(_ response: MarketResponse)
}

final class TextViewLogger: LoggerProtocol {
    let textView: UITextView
    
    init(textView: UITextView) {
        self.textView = textView
    }
    
    func logAction(_ action: Action, for currency: Currency) {
        textView.insertText("\(currency.name) \(currency.value) - to \(action)\n")
    }
    
    func logLastDealResult(_ dealHistory: [Deal]) {
        if let lastDeal = dealHistory.last {
            var actionToSearch: Action
            var fromValue: Double = .zero
            let toValue: Double = lastDeal.currency.quantity * lastDeal.currency.value
            var income: Double {
                return toValue - fromValue
            }
            switch lastDeal.action {
            case .purchase:
                actionToSearch = .sell
            case .sell:
                actionToSearch = .purchase
            case .ignore:
                return
            }
            if let deal = dealHistory.last(where: { $0.action == actionToSearch && $0.currency.name == lastDeal.currency.name }) {
                fromValue = lastDeal.currency.quantity * deal.currency.value
            }
            textView.insertText("\(lastDeal.action) FROM = \(fromValue) -> TO = \(toValue), INCOME = \(income)\n")
        }
    }
    
    func logMarketResponse(_ response: MarketResponse) {
        switch response.status {
        case .success:
            textView.insertText("Request approved\n")
        case .failure:
            textView.insertText("Request declined, reason: \(response.messege ?? "No reason provided")\n")
        }
    }
}
