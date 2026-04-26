//
//  Offer.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation

struct Offer {
    let id: UUID
    let currencyPair: CurrencyPair
    let exchangeRate: Double
    let isNetworkOffer: Bool
    
    init(id: UUID, currencyPair: CurrencyPair, isNetworkOffer: Bool = false, withDeviation: Bool = true) {
        self.id = id
        var newCurrency: RandomlyGeneratedCurrency
        if withDeviation {
            newCurrency = Offer.setValueAndQuantityDeviation(for: currencyPair.secondCurrency)
        } else {
            newCurrency = currencyPair.secondCurrency
        }
        
        self.currencyPair = CurrencyPair(firstCurrency: currencyPair.firstCurrency, secondCurrency: newCurrency)
        self.exchangeRate = Market.conversionRate(fromCurrency: currencyPair.firstCurrency, toCurrency: newCurrency)
        self.isNetworkOffer = isNetworkOffer
    }
}

// MARK: Private Methods
private extension Offer {
    static func setValueAndQuantityDeviation(for currency: RandomlyGeneratedCurrency) -> RandomlyGeneratedCurrency {
        let quantityDeviation = currency.quantity * Double.random(in: .zero...Constraints.quantityPercentileDeviation) / 100
        let newQuantity = currency.quantity - quantityDeviation
        let valueDeviation = currency.value * Double.random(in: .zero...Constraints.valuePercentileDeviation) / 100
        let newValue = currency.value - valueDeviation
        let newCurrency = RandomlyGeneratedCurrency(
            id: currency.id,
            name: currency.name,
            value: newValue,
            quantity: newQuantity,
            type: currency.type,
            isChosen: currency.isChosen,
            isFavorited: currency.isFavorited,
            isFromNet: currency.isFromNet
        )
        return newCurrency
    }
}

extension Offer {
    static func changeQuantityForCurrencies(offer: Offer, firstCurrencyQuantity: Double, secondCurrencyQuantity: Double) -> Offer {
        let newFirstCurrency = RandomlyGeneratedCurrency.changeQuanityForCurrency(
            currency: offer.currencyPair.firstCurrency,
            newQuantity: firstCurrencyQuantity
        )
        let newSecondCurrency = RandomlyGeneratedCurrency.changeQuanityForCurrency(
            currency: offer.currencyPair.secondCurrency,
            newQuantity: secondCurrencyQuantity
        )
        
        let newPair = CurrencyPair(firstCurrency: newFirstCurrency, secondCurrency: newSecondCurrency)
        
        let newOffer = Offer(
            id: offer.id,
            currencyPair: newPair,
            isNetworkOffer: offer.isNetworkOffer,
            withDeviation: false
        )
        
        return newOffer
    }
}

// MARK: - Constants
private extension Offer {
    enum Constraints {
        static let valuePercentileDeviation: Double = 4
        static let quantityPercentileDeviation: Double = 20
    }
}
