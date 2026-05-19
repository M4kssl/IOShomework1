//
//  TradingServiceTests.swift
//  TradingAppTests
//
//  Created by Максим  on 14.05.2026.
//

import Foundation
import XCTest
import Combine
@testable import homework4

final class TradingServiceWithOnlyLocalCurrenciesTest: XCTestCase {
    private var sut: TradingServiceProtocol!
    private var wallet: WalletMock!
    private var walletHandler: WalletHandlerMock!
    private var currencyFetcher: CurrencyFetcherMock!
    private var currencies = [RandomlyGeneratedCurrency]()
    private var tradingDelegate: TradingServiceDelegateMock!
    
    override func setUp() {
        super.setUp()
        
        wallet = WalletMock()
        currencyFetcher = CurrencyFetcherMock()
        walletHandler = WalletHandlerMock()
        tradingDelegate = TradingServiceDelegateMock()
        let currencyNames = RandomlyGeneratedCurrency.generateRandomNames(quantityOfNames: 2)
        for name in currencyNames {
            currencies.append(
                RandomlyGeneratedCurrency(
                    id: UUID(),
                    name: name,
                    value: 10,
                    quantity: 100,
                    type: CurrencyType.allCases.randomElement() ?? .crypto,
                    isChosen: false,
                    isFavorited: false,
                    isFromNet: false
                )
            )
        }
        
        sut = TradingService(
            wallet: wallet,
            walletHandler: walletHandler,
            localCurrencies: currencies,
            currencyFetcher: currencyFetcher
        )
        
        sut.setDelegate(tradingDelegate)
    }
    
    override func tearDown() {
        sut = nil
        wallet = nil
        currencyFetcher = nil
        walletHandler = nil
        tradingDelegate = nil
        //cancellables = nil
        currencies.removeAll()
        super.tearDown()
    }
    
    // MARK: - UpdateCurencies
    func test_updateCurrenciesWhenUpdatedWithEmptyArray() {
        sut.updateCurrencies(newCurrencies: [])
        XCTAssertEqual(0, sut.networkCurrencies?.count ?? 0)
        XCTAssertEqual(0, sut.localCurrencies.count)
    }
    
    func test_updateCurrenciesWhenUpdatedWithOnlyLocalCurrency() {
        let localCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        sut.updateCurrencies(newCurrencies: [localCurrency])
        XCTAssertEqual(0, sut.networkCurrencies?.count ?? 0)
        XCTAssertTrue(sut.localCurrencies.contains(where: { $0.id == localCurrency.id }))
    }
    
    func test_updateCurrenciesWhenUpdatedWithOnlyNetworkCurrency() {
        let netCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        sut.updateCurrencies(newCurrencies: [netCurrency])
        XCTAssertTrue(sut.networkCurrencies?.contains(where: { $0.id == netCurrency.id }) ?? false)
        XCTAssertEqual(0, sut.localCurrencies.count)
    }
    
    func test_updateCurrenciesWhenUpdatedWithLocalAndNetworkCurrencies() {
        let netCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        let localCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        sut.updateCurrencies(newCurrencies: [localCurrency, netCurrency])
        XCTAssertTrue(sut.networkCurrencies?.contains(where: { $0.id == netCurrency.id }) ?? false)
        XCTAssertTrue(sut.localCurrencies.contains(where: { $0.id == localCurrency.id }))
    }
    
    // MARK: - SetNewOffers
    func test_setNewOffersWhenNewOffersAreEmpty() {
        sut.setNewOffers([])
        XCTAssertTrue(sut.offers.isEmpty)
    }
    
    func test_setNewOfferssWhenNewOffersAreNotEmpty() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1)
        let offer = Offer(id: UUID(), currencyPair: pair)
        
        sut.setNewOffers([offer, offer, offer])
        
        XCTAssertEqual(3, sut.offers.count)
    }
    
    // MARK: - SortOffersByRate
    func test_sortOffersByRate() {
        let currentOffers = sut.offers
        
        let sortedOffers = currentOffers.sorted { $0.exchangeRate >= $1.exchangeRate }
        let expectation = getIndentifierArrayFromOfferArray(array: sortedOffers)
        sut.sortOffersByRate()
        
        XCTAssertEqual(expectation, getIndentifierArrayFromOfferArray(array: sut.offers))
    }
    
    // MARK: - SetDelegate
    func test_setDelegateSuccess() {
        let newDelegate = TradingServiceDelegateMock()
        sut.setDelegate(newDelegate)
        
        XCTAssertTrue(newDelegate === sut.delegate)
    }
    
    // MARK: - GetAllCurrenciesSnapshot
    func test_getAllCurrenciesSnapshot() {
        let netQuantity = sut.networkCurrencies?.count ?? 0
        let localQuantity = sut.localCurrencies.count
        
        XCTAssertEqual(netQuantity + localQuantity, sut.getAllCurrenciesSnapshot().count)
    }
    
    // MARK: - CurrentOffersSnapshot
    func test_currentOffersSnapshotWhenNoCurrencyIsSelected() {
        let allOffersQuantity = sut.offers.count
        let snapshotQuantity = sut.currentOffersSnapshot().count
        
        XCTAssertEqual(allOffersQuantity, snapshotQuantity)
    }
    
    func test_currentOffersSnapshotWhenFirstCurrencyIsChosen() {
        let firstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let secondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let thirdCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let chosenCurrency = firstCurrency
        var chosenCurrencyOfferCount = 0
        let chosenPair =  CurrencyPair(
            firstCurrency: chosenCurrency,
            secondCurrency: RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        )
        
        var newOffers = [Offer]()
        let newCurrencies = [firstCurrency, secondCurrency, thirdCurrency]
        for i in 0..<newCurrencies.count {
            for j in 0..<newCurrencies.count {
                if i != j {
                    if chosenCurrency.id == newCurrencies[i].id {
                        chosenCurrencyOfferCount += 1
                    }
                    let newPair = CurrencyPair(firstCurrency: newCurrencies[i], secondCurrency: newCurrencies[j])
                    newOffers.append(Offer(id: UUID(), currencyPair: newPair))
                }
            }
        }
        
        let newOffersCount = newOffers.count
        
        sut.setNewOffers(newOffers)
        XCTAssertEqual(newOffersCount, sut.offers.count)
        
        sut.setNewCurrencyPair(newPair: chosenPair)
        XCTAssertEqual(chosenCurrency.id, sut.currencyPair.firstCurrency.id)
        XCTAssertEqual(UUID.empty, sut.currencyPair.secondCurrency.id)
        
        let snapshotCount = sut.currentOffersSnapshot().count
        
        XCTAssertEqual(chosenCurrencyOfferCount, snapshotCount)
    }
    
    func test_currentOffersSnapshotWhenSecondCurrencyIsChosen() {
        let firstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let secondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let thirdCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let chosenCurrency = firstCurrency
        var chosenCurrencyOfferCount = 0
        let chosenPair =  CurrencyPair(
            firstCurrency: RandomlyGeneratedCurrency.generatePlaceholderCurrency(),
            secondCurrency: chosenCurrency
        )
        
        var newOffers = [Offer]()
        let newCurrencies = [firstCurrency, secondCurrency, thirdCurrency]
        for i in 0..<newCurrencies.count {
            for j in 0..<newCurrencies.count {
                if i != j {
                    if chosenCurrency.id == newCurrencies[j].id {
                        chosenCurrencyOfferCount += 1
                    }
                    let newPair = CurrencyPair(firstCurrency: newCurrencies[i], secondCurrency: newCurrencies[j])
                    newOffers.append(Offer(id: UUID(), currencyPair: newPair))
                }
            }
        }
        
        let newOffersCount = newOffers.count
        
        sut.setNewOffers(newOffers)
        XCTAssertEqual(newOffersCount, sut.offers.count)
        
        sut.setNewCurrencyPair(newPair: chosenPair)
        XCTAssertEqual(chosenCurrency.id, sut.currencyPair.secondCurrency.id)
        XCTAssertEqual(UUID.empty, sut.currencyPair.firstCurrency.id)
        
        let snapshotCount = sut.currentOffersSnapshot().count
        
        XCTAssertEqual(chosenCurrencyOfferCount, snapshotCount)
    }
    
    func test_currentOffersSnapshotWhenBothCurrenciesAreChosen() {
        let firstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let secondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let thirdCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let firstChosenCurrency = firstCurrency
        let secondChosenCurrency = secondCurrency
        var chosenCurrencyOfferCount = 0
        let chosenPair =  CurrencyPair(
            firstCurrency: firstChosenCurrency,
            secondCurrency: secondChosenCurrency
        )
        
        var newOffers = [Offer]()
        let newCurrencies = [firstCurrency, secondCurrency, thirdCurrency]
        for i in 0..<newCurrencies.count {
            for j in 0..<newCurrencies.count {
                if i != j {
                    if firstChosenCurrency.id == newCurrencies[i].id && secondChosenCurrency.id == newCurrencies[j].id {
                        chosenCurrencyOfferCount += 1
                    }
                    let newPair = CurrencyPair(firstCurrency: newCurrencies[i], secondCurrency: newCurrencies[j])
                    newOffers.append(Offer(id: UUID(), currencyPair: newPair))
                }
            }
        }
        
        let newOffersCount = newOffers.count
        
        sut.setNewOffers(newOffers)
        XCTAssertEqual(newOffersCount, sut.offers.count)
        
        sut.setNewCurrencyPair(newPair: chosenPair)
        XCTAssertEqual(sut.currencyPair.firstCurrency.id, firstChosenCurrency.id)
        XCTAssertEqual(sut.currencyPair.secondCurrency.id, secondChosenCurrency.id)
        
        let snapshotCount = sut.currentOffersSnapshot().count
        
        XCTAssertEqual(snapshotCount, chosenCurrencyOfferCount)
    }
    
    // MARK: - AddInitalBalacnceToNetworkCurrencies
    func test_addInitalBalacnceToNetworkCurrencies() {
        sut.addInitialBalanceForNetworkCurrencies()
        let networkCurrenciesQuantity = sut.networkCurrencies?.count ?? 0
        
        XCTAssertEqual(networkCurrenciesQuantity, walletHandler.addCurrencyCounter)
    }
    
    // MARK: - SetNewCurrencyPair
    func test_setNewCurrencyPair() {
        let firstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let secondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "NAME2",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: false
        )
        
        let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency)
        
        sut.setNewCurrencyPair(newPair: pair)
        
        XCTAssert(firstCurrency.id == sut.currencyPair.firstCurrency.id)
        XCTAssert(secondCurrency.id == sut.currencyPair.secondCurrency.id)
    }
    
    // MARK: - MakePurchase
    func test_makePurchaseSuccessWhenCombineIsNotUsed() {
        let firstCurrency = currencies[0]
        let secondCurrency = currencies[1]
        let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantityToBuy: Double = 10
        
        sut.setNewOffers([offer])
        walletHandler.calcultateQuantityAndPurchaseResult = .success(quantityToBuy)
        wallet.currencies[firstCurrency.id] = firstCurrency
        wallet.currencies[secondCurrency.id] = secondCurrency
        
        currencyFetcher.purchaseResult = .success(true)
        
        let offersUpdatedExpectation = expectation(description: "offersUpdated called")
        tradingDelegate.offersUpdatedHandler = {
            offersUpdatedExpectation.fulfill()
        }
        
        sut.makePurchase(offer, quantity: quantityToBuy, isCombineUsed: false)
        
        wait(for: [offersUpdatedExpectation], timeout: 1)
        
        XCTAssertEqual(walletHandler.addCurrencyCounter, 1)
        XCTAssertEqual(walletHandler.lastAddedCurrency?.id, secondCurrency.id)
        XCTAssertEqual(walletHandler.lastAddedQuantity, quantityToBuy)
        
        let updatedOffer = sut.offers.first
        XCTAssertEqual(updatedOffer?.currencyPair.firstCurrency.quantity, 110)
        XCTAssertEqual(updatedOffer?.currencyPair.secondCurrency.quantity, 90)
    }
    
    func test_makePurchaseFailureDueToWithdrawalErrorWhenCombineIsNotUsed() {
        let firstCurrency = currencies[0]
        let secondCurrency = currencies[1]
        let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantityToBuy: Double = 10
        
        sut.setNewOffers([offer])
        walletHandler.calcultateQuantityAndPurchaseResult = .failure(WalletError.notEnoughtFounds)
        walletHandler.withdrawalError = WalletError.notEnoughtFounds
        wallet.currencies[firstCurrency.id] = firstCurrency
        wallet.currencies[secondCurrency.id] = secondCurrency
        
        let errorExpectation = expectation(description: "Error reached delegate")
        tradingDelegate.handleErrorHandler = { error in
            XCTAssertEqual(error as? WalletError, WalletError.notEnoughtFounds)
            errorExpectation.fulfill()
        }
        
        sut.makePurchase(offer, quantity: quantityToBuy, isCombineUsed: false)
        
        wait(for: [errorExpectation], timeout: 1)
        
        XCTAssertEqual(walletHandler.addCurrencyCounter, 0)
        
        let unchangedOffer = sut.offers.first
        XCTAssertEqual(unchangedOffer?.currencyPair.firstCurrency.quantity, 100)
        XCTAssertEqual(unchangedOffer?.currencyPair.secondCurrency.quantity, 100)
    }
    
    func test_makePurchaseFailureDueToNetworkErrorWithRolledBackChangesWhenCombineIsNotUsed() {
        let firstCurrency = currencies[0]
        let secondCurrency = currencies[1]
        let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantityToBuy: Double = 10
        
        sut.setNewOffers([offer])
        walletHandler.calcultateQuantityAndPurchaseResult = .success(quantityToBuy)
        currencyFetcher.purchaseResult = .failure(NetworkError.NoIntertnetConnection)
        wallet.currencies[firstCurrency.id] = firstCurrency
        wallet.currencies[secondCurrency.id] = secondCurrency
        
        let errorExpectation = expectation(description: "Error reached delegate")
        tradingDelegate.handleErrorHandler = { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
            errorExpectation.fulfill()
        }
        
        sut.makePurchase(offer, quantity: quantityToBuy, isCombineUsed: false)
        
        wait(for: [errorExpectation], timeout: 1)
        
        XCTAssertEqual(walletHandler.addCurrencyCounter, 2)
        wallet.currencies.forEach { XCTAssertEqual($0.value.quantity, 100) }
        
        let unchangedOffer = sut.offers.first
        XCTAssertEqual(unchangedOffer?.currencyPair.firstCurrency.quantity, 100)
        XCTAssertEqual(unchangedOffer?.currencyPair.secondCurrency.quantity, 100)
    }
    
    func test_makePurchaseSuccessWhenCombineIsUsed() {
        let firstCurrency = currencies[0]
        let secondCurrency = currencies[1]
        let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantityToBuy: Double = 10
        
        sut.setNewOffers([offer])
        walletHandler.calcultateQuantityAndPurchaseResult = .success(quantityToBuy)
        wallet.currencies[firstCurrency.id] = firstCurrency
        wallet.currencies[secondCurrency.id] = secondCurrency
        
        currencyFetcher.purchaseCombineResult = Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let offersUpdatedExpectation = expectation(description: "offersUpdated called")
        tradingDelegate.offersUpdatedHandler = {
            offersUpdatedExpectation.fulfill()
        }
        
        sut.makePurchase(offer, quantity: quantityToBuy, isCombineUsed: true)
        
        wait(for: [offersUpdatedExpectation], timeout: 1)
        
        XCTAssertEqual(walletHandler.addCurrencyCounter, 1)
        XCTAssertEqual(walletHandler.lastAddedCurrency?.id, secondCurrency.id)
        XCTAssertEqual(walletHandler.lastAddedQuantity, quantityToBuy)
        
        let updatedOffer = sut.offers.first
        XCTAssertEqual(updatedOffer?.currencyPair.firstCurrency.quantity, 110)
        XCTAssertEqual(updatedOffer?.currencyPair.secondCurrency.quantity, 90)
    }
    
    func test_makePurchaseFailureDueToWithdrawalErrorWhenCombineIsUsed() {
        let firstCurrency = currencies[0]
        let secondCurrency = currencies[1]
        let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantityToBuy: Double = 10
        
        sut.setNewOffers([offer])
        walletHandler.calcultateQuantityAndPurchaseResult = .failure(WalletError.notEnoughtFounds)
        walletHandler.withdrawalError = WalletError.notEnoughtFounds
        wallet.currencies[firstCurrency.id] = firstCurrency
        wallet.currencies[secondCurrency.id] = secondCurrency
        
        let errorExpectation = expectation(description: "Error reached delegate")
        tradingDelegate.handleErrorHandler = { error in
            XCTAssertEqual(error as? WalletError, WalletError.notEnoughtFounds)
            errorExpectation.fulfill()
        }
        
        sut.makePurchase(offer, quantity: quantityToBuy, isCombineUsed: true)
        
        wait(for: [errorExpectation], timeout: 1)
        
        XCTAssertEqual(walletHandler.addCurrencyCounter, 0)
        
        let unchangedOffer = sut.offers.first
        XCTAssertEqual(unchangedOffer?.currencyPair.firstCurrency.quantity, 100)
        XCTAssertEqual(unchangedOffer?.currencyPair.secondCurrency.quantity, 100)
    }
    
    func test_makePurchaseFailureDueToNetworkErrorWithRolledBackChangesWhenCombineIsUsed() {
        let firstCurrency = currencies[0]
        let secondCurrency = currencies[1]
        let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantityToBuy: Double = 10
        
        sut.setNewOffers([offer])
        walletHandler.calcultateQuantityAndPurchaseResult = .success(quantityToBuy)
        currencyFetcher.purchaseCombineResult = Fail(error: NetworkError.NoIntertnetConnection)
            .eraseToAnyPublisher()
        wallet.currencies[firstCurrency.id] = firstCurrency
        wallet.currencies[secondCurrency.id] = secondCurrency
        
        let errorExpectation = expectation(description: "Error reached delegate")
        tradingDelegate.handleErrorHandler = { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
            errorExpectation.fulfill()
        }
        
        sut.makePurchase(offer, quantity: quantityToBuy, isCombineUsed: true)
        
        wait(for: [errorExpectation], timeout: 1)
        
        XCTAssertEqual(walletHandler.addCurrencyCounter, 2)
        wallet.currencies.forEach { XCTAssertEqual($0.value.quantity, 100) }
        
        let unchangedOffer = sut.offers.first
        XCTAssertEqual(unchangedOffer?.currencyPair.firstCurrency.quantity, 100)
        XCTAssertEqual(unchangedOffer?.currencyPair.secondCurrency.quantity, 100)
    }
    
    // MARK: - UpdateNetworkCurrencies
    func test_updateNetworkCurrenciesSuccessWhenCombineIsNotUsed() {
        let firstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "FIRST",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        let secondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "SECOND",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        let firstPair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency)
        let secondPair = CurrencyPair(firstCurrency: secondCurrency, secondCurrency: firstCurrency)
        let response = CurrencyFetcherResponse(
            uniqueCurrencies: [firstCurrency, secondCurrency],
            currencyPairs: [firstPair, secondPair]
        )
        
        let expectation = XCTestExpectation(description: "Network currencies update is successfull")
           
        currencyFetcher.fetchResult = .success(response)
           
        tradingDelegate.offersUpdatedHandler = {
           expectation.fulfill()
        }
        
        sut.updateNetworkCurrencies(isCombineUsed: false)
       
        wait(for: [expectation], timeout: 1.0)
       
        let networkCurrencies = sut.networkCurrencies
        XCTAssertNotNil(networkCurrencies)
        XCTAssertEqual(networkCurrencies?.count, 2)
        XCTAssertEqual(networkCurrencies?.first?.name, "FIRST")
       
        let offers = sut.currentOffersSnapshot()
        XCTAssertEqual(offers.count, 4)
       
        let networkOffers = offers.filter { $0.isNetworkOffer }
        XCTAssertEqual(networkOffers.count, 2)
       
        XCTAssertFalse(tradingDelegate.handleErrorCalled)
    }
    
    func test_updateNetworkCurrenciesFailureWhenCombineIsNotUsed() {
        let errorExpectation = XCTestExpectation(description: "Error reached delegate")
           
        currencyFetcher.fetchResult = .failure(NetworkError.NoIntertnetConnection)
       
        tradingDelegate.handleErrorHandler = { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
            errorExpectation.fulfill()
        }
       
        sut.updateNetworkCurrencies(isCombineUsed: false)
        wait(for: [errorExpectation], timeout: 1.0)
       
        XCTAssertTrue(tradingDelegate.handleErrorCalled)
        XCTAssertNil(sut.networkCurrencies)
       
        let offers = sut.currentOffersSnapshot()
        XCTAssertEqual(offers.count, 2)
        
        let networkOffers = offers.filter { $0.isNetworkOffer }
        XCTAssertEqual(networkOffers.count, 0)
    }
    
    func test_updateNetworkCurrenciesSuccessWhenCombineIsUsed() {
        let firstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "FIRST",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        let secondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "SECOND",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        let firstPair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency)
        let secondPair = CurrencyPair(firstCurrency: secondCurrency, secondCurrency: firstCurrency)
        let response = CurrencyFetcherResponse(
            uniqueCurrencies: [firstCurrency, secondCurrency],
            currencyPairs: [firstPair, secondPair]
        )
        
        let expectation = XCTestExpectation(description: "Network currencies update is successfull")
           
        currencyFetcher.fetchCombineResult = Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        tradingDelegate.offersUpdatedHandler = {
            expectation.fulfill()
        }
        
        sut.updateNetworkCurrencies(isCombineUsed: true)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(sut.networkCurrencies)
        XCTAssertEqual(sut.networkCurrencies?.count, 2)
        XCTAssertEqual(sut.networkCurrencies?.first?.name, "FIRST")
        
        let offers = sut.currentOffersSnapshot()
        let networkOffers = offers.filter { $0.isNetworkOffer }
        XCTAssertEqual(networkOffers.count, 2)
        
        XCTAssertTrue(tradingDelegate.offersUpdatedCalled)
        XCTAssertFalse(tradingDelegate.handleErrorCalled)
    }
    
    func test_updateNetworkCurrenciesFailureWhenCombineIsUsed() {
        let errorExpectation = XCTestExpectation(description: "Error reached delegate")
           
        currencyFetcher.fetchCombineResult = Fail(error: NetworkError.NoIntertnetConnection)
            .eraseToAnyPublisher()
       
        tradingDelegate.handleErrorHandler = { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
            errorExpectation.fulfill()
        }
       
        sut.updateNetworkCurrencies(isCombineUsed: true)
        wait(for: [errorExpectation], timeout: 1.0)
       
        XCTAssertTrue(tradingDelegate.handleErrorCalled)
        XCTAssertNil(sut.networkCurrencies)
       
        let offers = sut.currentOffersSnapshot()
        XCTAssertEqual(offers.count, 2)
        
        let networkOffers = offers.filter { $0.isNetworkOffer }
        XCTAssertEqual(networkOffers.count, 0)
    }
    
    // MARK: - AddInitialBalanceForNetworkCurrencies
    func test_addInitialBalanceForNetworkCurrenciesWhenCurrenciesAreLoaded() {
        let firstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "FIRST",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        let secondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "SECOND",
            value: 1,
            quantity: 1,
            type: .crypto,
            isFromNet: true
        )
        
        let firstPair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency)
        let secondPair = CurrencyPair(firstCurrency: secondCurrency, secondCurrency: firstCurrency)
        let response = CurrencyFetcherResponse(
            uniqueCurrencies: [firstCurrency, secondCurrency],
            currencyPairs: [firstPair, secondPair]
        )
        
        let expectation = XCTestExpectation(description: "Network currencies update is successfull")
           
        currencyFetcher.fetchCombineResult = Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        tradingDelegate.offersUpdatedHandler = {
            expectation.fulfill()
        }
        
        sut.updateNetworkCurrencies(isCombineUsed: true)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(sut.networkCurrencies)
        XCTAssertEqual(sut.networkCurrencies?.count, 2)
        XCTAssertEqual(sut.networkCurrencies?.first?.name, "FIRST")
        
        let offers = sut.currentOffersSnapshot()
        let networkOffers = offers.filter { $0.isNetworkOffer }
        XCTAssertEqual(networkOffers.count, 2)
        
        XCTAssertTrue(tradingDelegate.offersUpdatedCalled)
        XCTAssertFalse(tradingDelegate.handleErrorCalled)
        
        sut.addInitialBalanceForNetworkCurrencies()
        XCTAssertEqual(wallet.currencies[firstCurrency.id]?.quantity ?? 0, 10000)
        XCTAssertEqual(wallet.currencies[secondCurrency.id]?.quantity ?? 0, 10000)
    }
    
    func test_addInitialBalanceForNetworkCurrenciesWhenCurrenciesAreNotLoaded() {
        sut.addInitialBalanceForNetworkCurrencies()
        XCTAssertEqual(wallet.currencies.count, 0)
    }
    
    // MARK: - GenerateLocalOffers
    func test_generateLocalOffersWhenNoLocalCurrenciesArePresent() {
        sut.updateCurrencies(newCurrencies: [])
        XCTAssertTrue(sut.getAllCurrenciesSnapshot().isEmpty)
        
        sut.generateLocalOffers()
        XCTAssertTrue(sut.offers.isEmpty)
    }
    
    func test_generateLocalOffersWhenCurrenciesArePresent() {
        let amountOfCurrencies = sut.localCurrencies.count
        let expectedOfferssCount = amountOfCurrencies * amountOfCurrencies - amountOfCurrencies
        
        sut.generateLocalOffers()
        XCTAssertEqual(sut.offers.count, expectedOfferssCount)
    }
    
}

private extension TradingServiceWithOnlyLocalCurrenciesTest {
    func getIndentifierArrayFromOfferArray(array: [Offer]) -> [UUID] {
        var result = [UUID]()
        for item in array {
            result.append(item.id)
        }
        return result
    }
}
