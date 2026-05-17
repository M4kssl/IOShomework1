//
//  WalletHandlerTests.swift
//  TradingAppTests
//
//  Created by Максим  on 16.05.2026.
//

import Foundation
import XCTest
@testable import homework4

final class WalletHandlerTests: XCTestCase {
    private var wallet: WalletMock!
    private var sut: WalletHandler!
    
    override func setUp() {
        super.setUp()
        wallet = WalletMock()
        sut = WalletHandler()
    }
    
    // MARK: - addCurrency
    func test_addCurrencyWhenWalletIsEmpty() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        sut.addCurrency(currency, quantity: 10, wallet: wallet)
        XCTAssertEqual(wallet.currencies.count , 1)
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, 10)
    }
    
    func test_addCurrencyWhenWalletHasAddedCurrency() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currency.id] = currency
        
        sut.addCurrency(currency, quantity: 10, wallet: wallet)
        XCTAssertEqual(wallet.currencies.count , 1)
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, 20)
    }
    
    func test_addCurrencyWhenAddingNegativeQuantityAndWalletIsEmpty() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        sut.addCurrency(currency, quantity: -10, wallet: wallet)
        XCTAssertEqual(wallet.currencies.count , 1)
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, -10)
    }
    
    func test_addCurrencyWhenAddingNegativeQuantityAndWalletHasAddedCurrency() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currency.id] = currency
        
        sut.addCurrency(currency, quantity: -10, wallet: wallet)
        XCTAssertEqual(wallet.currencies.count , 1)
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, 0)
    }
    
    func  test_addCurrencyWhenWalletHasAnotherCurrency() {
        let existingCurrency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        
        wallet.currencies[existingCurrency.id] = existingCurrency
        
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        sut.addCurrency(currency, quantity: 10, wallet: wallet)
        XCTAssertEqual(wallet.currencies.count , 2)
        
        let walletCurrencyQuantity = wallet.currencies.first(where: { $0.value.id == currency.id})?.value.quantity ?? 0
        XCTAssertEqual(walletCurrencyQuantity, 10)
    }
    
    func test_addCurrencyWhenWalletIsEmptyAndAddedQuantityIsZero() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        sut.addCurrency(currency, quantity: 0, wallet: wallet)
        XCTAssertEqual(wallet.currencies.count , 1)
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, 0)
    }
    
    // MARK: - withdrawCurrency
    func test_withdrawCurrencyFailureDueToWithdrawalQuantityBeingGreaterThanAvailableQuantity() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currency.id] = currency
        
        var expectedError: Error?
        
        do {
            try sut.withdrawCurrency(currency, quantity: 100, wallet: wallet)
        } catch {
            expectedError = error
        }
        
        XCTAssertNotNil(expectedError)
        XCTAssertTrue(expectedError is WalletError)
    }
    
    func test_withdrawCurrencySuccess() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currency.id] = currency
        
        do {
            try sut.withdrawCurrency(currency, quantity: 10, wallet: wallet)
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, 90)
    }
    
    func test_withdrawCurrencyWhenWhithdrawingNegativeQuantity() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currency.id] = currency
        
        do {
            try sut.withdrawCurrency(currency, quantity: -10, wallet: wallet)
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, 110)
    }
    
    func test_withdrawCurrencyWhenWhithdrawalQuantityIsZero() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currency.id] = currency
        
        do {
            try sut.withdrawCurrency(currency, quantity: 0, wallet: wallet)
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(wallet.currencies.first?.value.quantity ?? 0, 100)
    }
    
    func test_withdrawCurrencyFailureDueToWalletBeingEmpty() {
        let currency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR",
            value: 1,
            quantity: 10,
            type: .crypto,
            isFromNet: true
        )
        
        var expectedError: Error?
        
        do {
            try sut.withdrawCurrency(currency, quantity: 100, wallet: wallet)
        } catch {
            expectedError = error
        }
        
        XCTAssertNotNil(expectedError)
        XCTAssertTrue(expectedError is WalletError)
    }
    
    // MARK: - calcultateQuantityAndPurchaseIfAbleTo
    func test_calcultateQuantityAndPurchaseIfAbleToSuccess() {
        let currencyToBuy = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR1",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        let currencyToSell = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR2",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currencyToSell.id] = currencyToSell
        wallet.currencies[currencyToBuy.id] = currencyToBuy
        wallet.calculateQuantityToBuyResult = 10
        
        var boughtCurrenyQuantity = 0.0
        do {
             boughtCurrenyQuantity = try sut.calcultateQuantityAndPurchaseIfAbleTo(currencyToBuy: currencyToBuy, currencyToSell: currencyToSell, quantityToSell: 10, wallet: wallet)
        } catch {
            XCTFail()
        }
        
        let walletBoughtCurrencyQuantity = wallet.currencies.first(where: { $0.value.id == currencyToBuy.id})?.value.quantity ?? 0
        let walletSoldCurrencyQuantity = wallet.currencies.first(where: { $0.value.id == currencyToSell.id})?.value.quantity ?? 0
        
        XCTAssertEqual(walletSoldCurrencyQuantity, 90)
        XCTAssertEqual(walletBoughtCurrencyQuantity, 110)
        XCTAssertEqual(boughtCurrenyQuantity, 10)
    }
    
    func test_calcultateQuantityAndPurchaseIfAbleToFailureDueToWalletBeingEmpty() {
        let currencyToBuy = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR1",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        let currencyToSell = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR2",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        var expectedError: Error?
        var boughtCurrenyQuantity = 0.0
        
        do {
             boughtCurrenyQuantity = try sut.calcultateQuantityAndPurchaseIfAbleTo(currencyToBuy: currencyToBuy, currencyToSell: currencyToSell, quantityToSell: 10, wallet: wallet)
        } catch {
            expectedError = error
        }
        
        let walletBoughtCurrencyQuantity = wallet.currencies.first(where: { $0.value.id == currencyToBuy.id})?.value.quantity ?? 0
        let walletSoldCurrencyQuantity = wallet.currencies.first(where: { $0.value.id == currencyToSell.id})?.value.quantity ?? 0
        
        XCTAssertNotNil(expectedError)
        XCTAssertTrue(expectedError is WalletError)
        XCTAssertEqual(walletSoldCurrencyQuantity, 0)
        XCTAssertEqual(walletBoughtCurrencyQuantity, 0)
        XCTAssertEqual(boughtCurrenyQuantity, 0)
    }
    
    func test_calcultateQuantityAndPurchaseIfAbleToFailureDueToQuantityToSellBeingGreaterThanAvailableQuantity() {
        let currencyToBuy = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR1",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        let currencyToSell = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CUR2",
            value: 1,
            quantity: 100,
            type: .crypto,
            isFromNet: true
        )
        
        wallet.currencies[currencyToSell.id] = currencyToSell
        wallet.calculateQuantityToBuyResult = 0.0
        var expectedError: Error?
        var boughtCurrenyQuantity = 0.0
        
        do {
             boughtCurrenyQuantity = try sut.calcultateQuantityAndPurchaseIfAbleTo(
                currencyToBuy: currencyToBuy,
                currencyToSell: currencyToSell,
                quantityToSell: 1000,
                wallet: wallet
             )
        } catch {
            expectedError = error
        }
        
        let walletBoughtCurrencyQuantity = wallet.currencies.first(where: { $0.value.id == currencyToBuy.id})?.value.quantity ?? 0
        let walletSoldCurrencyQuantity = wallet.currencies.first(where: { $0.value.id == currencyToSell.id})?.value.quantity ?? 0
        
        XCTAssertNotNil(expectedError)
        XCTAssertTrue(expectedError is WalletError)
        XCTAssertEqual(walletSoldCurrencyQuantity, 100)
        XCTAssertEqual(walletBoughtCurrencyQuantity, 0)
        XCTAssertEqual(boughtCurrenyQuantity, 0)
    }
}
