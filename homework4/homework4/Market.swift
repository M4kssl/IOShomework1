//
//  Market.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import Foundation

struct Currency {
    let name: CurrencyName
    let quantity: Double
    let value: Double
    
    enum CurrencyName: String, CaseIterable {
        case usd
        case eur
        case gbp
        case jpy
    }
}

protocol MarketProtocol {
    var currencies: [Currency] { get }
    func updateCurrenciesValues()
    func processRequestAndFormAResponse(_ request: RequestForMarket) -> MarketResponse
}

struct MarketResponse {
    let request: RequestForMarket
    let status: MarketResponseStatus
    let messege: String?
    
    enum MarketResponseStatus: String {
        case success
        case failure
    }
}

final class Market: MarketProtocol {
    private(set) var currencies: [Currency] = []
    
    init(){
        for currency in Currency.CurrencyName.allCases {
            currencies.append(Currency(name: currency, quantity: 80, value: Double.random(in: 1...100)))
        }
    }
    
    func updateCurrenciesValues() {
        for index in currencies.indices {
            let newValue = Double.random(in: 1...100)
            currencies[index] = Currency(name: currencies[index].name,  quantity: currencies[index].quantity, value: newValue)
        }
    }
    
    func processRequestAndFormAResponse(_ request: RequestForMarket) -> MarketResponse {
        switch request.action {
        case .ignore:
            return MarketResponse(request: request, status: .success, messege: nil)
        case .purchase:
            if let index = currencies.firstIndex(where: { $0.name == request.currency.name }) {
                if currencies[index].quantity < request.quantity {
                    return MarketResponse(request: request, status: .failure, messege: "Not enough quantity avalible. Request for \(request.quantity), avalible \(currencies[index].quantity)")
                }
                let newQuantity = currencies[index].quantity - request.quantity
                currencies[index] = Currency(name: currencies[index].name,  quantity: newQuantity, value: currencies[index].value)
                return MarketResponse(request: request, status: .success, messege: nil)
            }
        case .sell:
            if let index = currencies.firstIndex(where: { $0.name == request.currency.name }) {
                let newQuantity = currencies[index].quantity + request.quantity
                currencies[index] = Currency(name: currencies[index].name,  quantity: newQuantity, value: currencies[index].value)
                return MarketResponse(request: request, status: .success, messege: nil)
            }
        }
        return MarketResponse(request: request, status: .failure, messege: "Something went wrong")
    }
}
