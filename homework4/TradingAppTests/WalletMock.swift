//
//  WalletMock.swift
//  TradingAppTests
//
//  Created by Максим  on 14.05.2026.
//

import Foundation
@testable import homework4

final class WalletMock: WalletProtocol {
    var currencies = [UUID: RandomlyGeneratedCurrency]()
    var confirmPurchaseShouldThrow = false
    var withdrawCurrencyShouldThrow = false
    var calculateQuantityToBuyResult: Double = 0
    
    func calculateQuantityToBuy(for currencyToBuy: RandomlyGeneratedCurrency, with currencyToSell: RandomlyGeneratedCurrency, quantityToSell: Double) -> Double {
        return calculateQuantityToBuyResult
    }
    
    func confirmPurchase(of currencyToBuy: RandomlyGeneratedCurrency, with currencyToSell: RandomlyGeneratedCurrency, inQuantity quantityToBuy: Double) throws {
        if confirmPurchaseShouldThrow {
            throw WalletError.notEnoughtFounds
        }
        addCurrency(currency: currencyToBuy, quantity: quantityToBuy)
        let conversionRate = Market.conversionRate(fromCurrency: currencyToSell, toCurrency: currencyToBuy)
        let quantityToSell = quantityToBuy / conversionRate
        try withdrawCurrency(currency: currencyToSell, quantity: quantityToSell)
    }
    
    func getCurrenciesOnHandSnapshot() -> [UUID : RandomlyGeneratedCurrency] {
        return currencies
    }
    
    func addCurrency(currency: RandomlyGeneratedCurrency, quantity: Double) {
        var newQuantity = quantity
        if let currencyOnHand = currencies[currency.id] {
            newQuantity += currencyOnHand.quantity
        }
        currencies[currency.id] = RandomlyGeneratedCurrency.changeQuanityForCurrency(currency: currency, newQuantity: newQuantity)
    }
    
    func withdrawCurrency(currency: RandomlyGeneratedCurrency, quantity: Double) throws {
        if withdrawCurrencyShouldThrow {
            throw WalletError.notEnoughtFounds
        }
        guard let currencyOnHand = currencies[currency.id], currencyOnHand.quantity >= quantity else {
            throw WalletError.notEnoughtFounds
        }
        let newQuantity = currencyOnHand.quantity - quantity
        currencies[currency.id] = RandomlyGeneratedCurrency.changeQuanityForCurrency(currency: currency, newQuantity: newQuantity)
    }
}
