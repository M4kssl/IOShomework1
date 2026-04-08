//
//  Market.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import Foundation

protocol MarketProtocol {
    var currencies: [UUID : RandomlyGeneratedCurrency] { get }
    func updateCurrenciesValues()
    func processRequestAndFormAResponse(_ request: RequestForMarket) -> MarketResponse
    func getAllCurrencies() -> [RandomlyGeneratedCurrency]
    func updateCurrencies(with currencies: [RandomlyGeneratedCurrency])
}

struct MarketResponse {
    let request: RequestForMarket
    let status: MarketResponseStatus
    let messege: String?
}

final class Market: MarketProtocol {
    private(set) var currencies = [UUID : RandomlyGeneratedCurrency]()
    
    init(amountOfCurrencies: Int) {
        let currencyNames = RandomlyGeneratedCurrency.generateRandomNames(quantityOfNames: amountOfCurrencies)
        for name in currencyNames {
            let currency = RandomlyGeneratedCurrency(
                id: UUID(),
                name: name,
                value: Double.random(in: DefaultValues.minimumCurrencyValue...DefaultValues.maximumCurrencyValue),
                quantity: DefaultValues.initialCurrencyQuantity,
                type: CurrencyType.allCases.randomElement() ?? .crypto,
                isChosen: false,
                isFavorited: false
            )
            currencies[currency.id] = currency
        }
    }
    
    func updateCurrenciesValues() {
        for key in currencies.keys {
            if let currency = currencies[key] {
                let newValue = Double.random(in: DefaultValues.minimumCurrencyValue...DefaultValues.maximumCurrencyValue)
                currencies[key] = RandomlyGeneratedCurrency(
                    id: currency.id,
                    name: currency.name,
                    value: newValue,
                    quantity: currency.quantity,
                    type: currency.type,
                    isChosen: currency.isChosen,
                    isFavorited: currency.isFavorited
                )
            }
        }
    }
    
    func processRequestAndFormAResponse(_ request: RequestForMarket) -> MarketResponse {
        switch request.action {
        case .ignore:
            return MarketResponse(request: request, status: .success, messege: nil)
        case .purchase:
            let key = request.currency.id
            if let currency = currencies[key] {
                if currency.quantity < request.quantity {
                    return MarketResponse(request: request, status: .failure, messege: "Not enough quantity avalible. Request for \(request.quantity), avalible \(currency.quantity)")
                }
                let newQuantity = currency.quantity - request.quantity
                currencies[key] = RandomlyGeneratedCurrency(
                    id: currency.id,
                    name: currency.name,
                    value: currency.value,
                    quantity: newQuantity,
                    type: currency.type,
                    isChosen: currency.isChosen,
                    isFavorited: currency.isFavorited
                )
                return MarketResponse(request: request, status: .success, messege: nil)
            }
        case .sell:
            let key = request.currency.id
            if let currency = currencies[key] {
                let newQuantity = currency.quantity + request.quantity
                currencies[key] = RandomlyGeneratedCurrency(
                    id: currency.id,
                    name: currency.name,
                    value: currency.value,
                    quantity: newQuantity,
                    type: currency.type,
                    isChosen: currency.isChosen,
                    isFavorited: currency.isFavorited
                )
                return MarketResponse(request: request, status: .success, messege: nil)
            }
        }
        return MarketResponse(request: request, status: .failure, messege: "Something went wrong")
    }
    
    func getAllCurrencies() -> [RandomlyGeneratedCurrency] {
        return Array(currencies.values)
    }
    
    func updateCurrencies(with currencies: [RandomlyGeneratedCurrency]) {
        for currency in currencies {
            self.currencies[currency.id] = currency
        }
    }
}

private extension Market {
    struct DefaultValues {
        static let minimumCurrencyValue: Double = 10
        static let maximumCurrencyValue: Double = 100
        static let initialCurrencyQuantity: Double = 80
    }
}

// MARK: - MarketResponse's nested types
extension MarketResponse {
    enum MarketResponseStatus: String {
        case success
        case failure
    }
}
