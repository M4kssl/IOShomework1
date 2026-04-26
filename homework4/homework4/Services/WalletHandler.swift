//
//  WalletHandler.swift
//  homework4
//
//  Created by Максим  on 21.04.2026.
//

import Foundation

protocol WalletHandlerProtocol {
    func calcultateQuantityAndPurchaseIfAbleTo(currencyToBuy: RandomlyGeneratedCurrency, currencyToSell: RandomlyGeneratedCurrency, quantityToSell: Double, wallet: WalletProtocol) throws -> Double
    func withdrawCurrency(_ currency: RandomlyGeneratedCurrency, quantity: Double, wallet: WalletProtocol) throws
    func addCurrency(_ currency: RandomlyGeneratedCurrency, quantity: Double, wallet: WalletProtocol)

}

final class WalletHandler: WalletHandlerProtocol {
    func calcultateQuantityAndPurchaseIfAbleTo(currencyToBuy: RandomlyGeneratedCurrency, currencyToSell: RandomlyGeneratedCurrency, quantityToSell: Double, wallet: WalletProtocol) throws -> Double {
        let quantityToBuy = wallet.calculateQuantityToBuy(for: currencyToBuy, with: currencyToSell, quantityToSell: quantityToSell)
        guard quantityToBuy > .zero else { throw WalletError.notEnoughtFounds }
        
        do {
            try wallet.confirmPurchase(
                of: currencyToBuy,
                with: currencyToSell,
                inQuantity: quantityToBuy
            )
        } catch {
            throw error
        }
        return quantityToBuy
    }
    
    func withdrawCurrency(_ currency: RandomlyGeneratedCurrency, quantity: Double, wallet: WalletProtocol) throws {
        do {
            try wallet.withdrawCurrency(currency: currency, quantity: quantity)
        } catch {
            throw error
        }
    }
    
    func addCurrency(_ currency: RandomlyGeneratedCurrency, quantity: Double, wallet: WalletProtocol) {
        wallet.addCurrency(currency: currency, quantity: quantity)
    }
}
