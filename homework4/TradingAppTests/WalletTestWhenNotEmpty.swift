//
//  WalletTestWhenNotEmpty.swift
//  TradingAppTests
//
//  Created by Максим  on 16.05.2026.
//

import Foundation
import XCTest
@testable import homework4

final class WalletTestWhenNotEmpty: XCTestCase {
    private var sut: Wallet!
    private var currency : RandomlyGeneratedCurrency!
    
    override func setUp() {
        super.setUp()
        currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        sut = Wallet(currencies: [currency])
    }
    
    // MARK: - getCurrenciesOnHandSnapshot
    func test_getCurrenciesOnHandSnapshotWhenWalletIsEmpty() {
        XCTAssertTrue(sut.getCurrenciesOnHandSnapshot().count == 1)
    }
    
    // MARK: - addCurrency
    func test_addCurrency() {
        sut.addCurrency(currency: currency, quantity: 10)
        XCTAssertEqual(sut.getCurrenciesOnHandSnapshot().count , 1)
        XCTAssertEqual(sut.getCurrenciesOnHandSnapshot().first?.value.quantity, 110)
    }
    
    // MARK: - withdrawCurrency
    func test_withdrawCurrencySuccess() {
        do {
            try sut.withdrawCurrency(currency: currency, quantity: 10)
        } catch {
            XCTFail()
        }
        XCTAssertEqual(sut.getCurrenciesOnHandSnapshot().first?.value.quantity, 90)
    }
    
    // MARK: - calculateQuantityToBuy
    func test_calculateQuantityToBuy() {
        let currencyToBuy = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "BUY",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        let currencyToSell = currency!
        
        let quantityToBuy = sut.calculateQuantityToBuy(for: currencyToBuy, with: currencyToSell, quantityToSell: 10)
        
        XCTAssertEqual(quantityToBuy, 10)
    }
    
    // MARK: - confirmPurchase
    func test_congfirmPurchaseSuccess() {
        let currencyToBuy = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "BUY",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        let currencyToSell = currency!
        
        do {
            try sut.confirmPurchase(of: currencyToBuy, with: currencyToSell, inQuantity: 10)
        } catch {
            XCTFail()
        }
    
        let walletCurrencies = sut.getCurrenciesOnHandSnapshot()
        XCTAssertFalse(walletCurrencies.isEmpty)
        
        let walletBoughtCurrencyQuantity = walletCurrencies.first(where: { $0.value.id == currencyToBuy.id})?.value.quantity ?? 0
        let walletSoldCurrencyQuantity = walletCurrencies.first(where: { $0.value.id == currencyToSell.id})?.value.quantity ?? 0
        
        XCTAssertEqual(walletSoldCurrencyQuantity, 90)
        XCTAssertEqual(walletBoughtCurrencyQuantity, 10)
    }
    
    func test_congfirmPurchaseFailureDueToNotHavingEnoughToSell() {
        let currencyToBuy = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "BUY",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        let currencyToSell = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "SELL",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        var expectedError: Error?
        do {
            try sut.confirmPurchase(of: currencyToBuy, with: currencyToSell, inQuantity: 10000)
        } catch {
            expectedError = error
        }
        XCTAssertNotNil(expectedError)
        XCTAssertTrue(expectedError is WalletError)
    }
}
