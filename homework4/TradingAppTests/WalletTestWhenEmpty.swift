//
//  WalletTestWhenEmpty.swift
//  TradingAppTests
//
//  Created by Максим  on 16.05.2026.
//

import Foundation
import XCTest
@testable import homework4

final class WalletTestWhenEmpty: XCTestCase {
    private var sut: Wallet!
    
    override func setUp() {
        super.setUp()
        sut = Wallet(currencies: [])
    }
    
    // MARK: - getCurrenciesOnHandSnapshot
    func test_getCurrenciesOnHandSnapshotWhenWalletIsEmpty() {
        XCTAssertTrue(sut.getCurrenciesOnHandSnapshot().isEmpty)
    }
    
    // MARK: - addCurrency
    func test_addCurrency() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        sut.addCurrency(currency: currency, quantity: 10)
        XCTAssertEqual(sut.getCurrenciesOnHandSnapshot().count , 1)
        XCTAssertEqual(sut.getCurrenciesOnHandSnapshot().first?.value.quantity, 10)
    }
    
    // MARK: - withdrawCurrency
    func test_withdrawCurrencyFailure() {
        var expectedError: Error?
        
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        
        do {
            try sut.withdrawCurrency(currency: currency, quantity: 10)
        } catch {
            expectedError = error
        }
        XCTAssertNotNil(expectedError)
        XCTAssertTrue(expectedError is WalletError)
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
        
        let currencyToSell = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "SELL",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        let quantityToBuy = sut.calculateQuantityToBuy(for: currencyToBuy, with: currencyToSell, quantityToSell: 100)
        
        XCTAssertEqual(quantityToBuy, .zero)
    }
    
    // MARK: - confirmPurchase
    func test_congfirmPurchaseFailure() {
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
            try sut.confirmPurchase(of: currencyToBuy, with: currencyToSell, inQuantity: 10)
        } catch {
            expectedError = error
        }
        XCTAssertNotNil(expectedError)
        XCTAssertTrue(expectedError is WalletError)
    }

}
