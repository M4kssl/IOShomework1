//
//  WalletHandlerMock.swift
//  TradingAppTests
//
//  Created by Максим  on 14.05.2026.
//

import Foundation
@testable import homework4

final class WalletHandlerMock: WalletHandlerProtocol {
    var calcultateQuantityAndPurchaseResult: Result<Double, Error> = .success(0)
    var withdrawalError: Error?
    var lastAddedCurrency: RandomlyGeneratedCurrency?
    var lastAddedQuantity: Double?
    var addCurrencyCounter: Int = 0
    var withdrawalCounter: Int = 0
    
    func calcultateQuantityAndPurchaseIfAbleTo(currencyToBuy: RandomlyGeneratedCurrency, currencyToSell: RandomlyGeneratedCurrency, quantityToSell: Double, wallet: WalletProtocol) throws -> Double {
        switch calcultateQuantityAndPurchaseResult {
        case .success(let quantity):
            return quantity
        case .failure(let error):
            throw error
        }
    }
    
    func withdrawCurrency(_ currency: RandomlyGeneratedCurrency, quantity: Double, wallet: WalletProtocol) throws {
        withdrawalCounter += 1
        if let error = withdrawalError {
            throw error
        }
        try wallet.withdrawCurrency(currency: currency, quantity: quantity)
    }
    
    func addCurrency(_ currency: RandomlyGeneratedCurrency, quantity: Double, wallet: WalletProtocol) {
        addCurrencyCounter += 1
        lastAddedCurrency = currency
        lastAddedQuantity = quantity
        wallet.addCurrency(currency: currency, quantity: quantity)
    }
}
