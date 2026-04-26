//
//  Wallet.swift
//  homework4
//
//  Created by Максим  on 20.04.2026.
//

import Foundation

protocol WalletProtocol {    
    func calculateQuantityToBuy(for currencyToBuy: RandomlyGeneratedCurrency, with currencyToSell: RandomlyGeneratedCurrency, quantityToSell: Double) -> Double
    func confirmPurchase(of currencyToBuy: RandomlyGeneratedCurrency, with currencyToSell: RandomlyGeneratedCurrency, inQuantity quantityToBuy: Double) throws
    func getCurrenciesOnHandSnapshot() -> [UUID : RandomlyGeneratedCurrency]
    func addCurrency(currency: RandomlyGeneratedCurrency, quantity: Double)
    func withdrawCurrency(currency: RandomlyGeneratedCurrency, quantity: Double) throws

}

final class Wallet: WalletProtocol {
    private var currenciesOnHand: [UUID : RandomlyGeneratedCurrency]
    
    private let lock = NSLock()
    
    init(currencies: [RandomlyGeneratedCurrency]) {
        currenciesOnHand = [UUID : RandomlyGeneratedCurrency]()
        
        for currency in currencies {
            currenciesOnHand[currency.id] = RandomlyGeneratedCurrency.changeQuanityForCurrency(
                currency: currency,
                newQuantity: DefaultValues.initialCurrencyQuantity
            )
        }
    }
    
    func addCurrency(currency: RandomlyGeneratedCurrency, quantity: Double) {
        lock.lock()
        defer { lock.unlock() }
        
        var newQuantity = quantity
        
        if let currencyOnHand = currenciesOnHand[currency.id] {
            newQuantity += currencyOnHand.quantity
        }
        
        let newCurrency = RandomlyGeneratedCurrency.changeQuanityForCurrency(
            currency: currency,
            newQuantity: newQuantity
        )
        
        currenciesOnHand[currency.id] = newCurrency
    }
    
    func withdrawCurrency(currency: RandomlyGeneratedCurrency, quantity: Double) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let currencyOnHand = currenciesOnHand[currency.id] else { throw WalletError.notEnoughtFounds }
        
        let quantityAfterWithdrawal = currencyOnHand.quantity - quantity
        
        guard quantityAfterWithdrawal > 0 else { throw WalletError.notEnoughtFounds }
        
        let newCurrency = RandomlyGeneratedCurrency.changeQuanityForCurrency(
            currency: currency,
            newQuantity: quantityAfterWithdrawal
        )
        currenciesOnHand[currency.id] = newCurrency
    }
    
    func confirmPurchase(of currencyToBuy: RandomlyGeneratedCurrency, with currencyToSell: RandomlyGeneratedCurrency, inQuantity quantityToBuy: Double) throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard let currencyToSellOnHand = currenciesOnHand[currencyToSell.id] else { return }
        
        let conversionRate = Market.conversionRate(fromCurrency: currencyToSell, toCurrency: currencyToBuy)
        let quantityToSell = quantityToBuy / conversionRate
        let quantityAfterSale = currencyToSellOnHand.quantity - quantityToSell
        
        guard quantityAfterSale > 0 else { throw WalletError.notEnoughtFounds }
        let newSoldCurrency = RandomlyGeneratedCurrency.changeQuanityForCurrency(
            currency: currencyToSell,
            newQuantity: quantityAfterSale
        )
        currenciesOnHand[currencyToSell.id] = newSoldCurrency
        
        var quantityAfterPurchase = quantityToBuy
        
        if let currencyToBuyOnHand = currenciesOnHand[currencyToBuy.id] {
            quantityAfterPurchase += currencyToBuyOnHand.quantity
        }
        
        let newBoughtCurrency = RandomlyGeneratedCurrency.changeQuanityForCurrency(
            currency: currencyToBuy,
            newQuantity: quantityAfterPurchase
        )
        
        currenciesOnHand[currencyToBuy.id] = newBoughtCurrency
    }
    
    func calculateQuantityToBuy(for currencyToBuy: RandomlyGeneratedCurrency, with currencyToSell: RandomlyGeneratedCurrency, quantityToSell: Double) -> Double {
        lock.lock()
        defer { lock.unlock() }
        
        let key = currencyToSell.id
        guard currenciesOnHand[key] != nil else { return .zero }
        
        let conversionRate = Market.conversionRate(fromCurrency: currencyToSell, toCurrency: currencyToBuy)
        let quantityToBuy = quantityToSell * conversionRate
        
        return quantityToBuy
    }
    
    func getCurrenciesOnHandSnapshot() -> [UUID : RandomlyGeneratedCurrency] {
        lock.lock()
        defer { lock.unlock() }
        return currenciesOnHand
    }

}

// MARK: - Constants
private extension Wallet {
    enum DefaultValues {
        static let initialCurrencyQuantity: Double = 100
    }
}

// MARK: - Wallet Errors
enum WalletError: Error {
    case notEnoughtFounds
}
