//
//  CurrencyFetcherTest.swift
//  TradingAppTests
//
//  Created by Максим  on 16.05.2026.
//

import Foundation
import XCTest
import Combine
@testable import homework4

final class CurrencyFetcherTest: XCTestCase {
    var sut: AlorCurrencyFetcher!
    var gateway: AlorGatewayMock!
    var requestMapper: AlorRequestMapperMock!
    var responseMapper: AlorResponseMapperMock!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        gateway = AlorGatewayMock()
        requestMapper = AlorRequestMapperMock()
        responseMapper = AlorResponseMapperMock()
        sut = AlorCurrencyFetcher(
            gateway: gateway,
            requestMapper: requestMapper,
            responseMapper: responseMapper
        )
        cancellables = []
    }
    
    // MARK: - fetchUniqueCurrenicesAndPairs
    func test_fetchUniqueCurrenicesAndPairsSuccess() {
        let alorPair = getAlorCurrencyPair()
        let domainPair = getDomainPair()
        
        gateway.fetchCurrencyDataResult = .success([alorPair])
        responseMapper.convertedCurrencyPairs = [domainPair]
        
        let expectation = XCTestExpectation(description: "Fetch completed")
        
        sut.fetchUniqueCurrenicesAndPairs { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.currencyPairs.count, 1)
                XCTAssertEqual(response.uniqueCurrencies.count, 2)
                XCTAssertTrue(self.gateway.fetchCurrencyDataCalled)
            case .failure(let error):
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchUniqueCurrenicesAndPairsFailureDueToEmptyAlorPairs() {
        gateway.fetchCurrencyDataResult = .success([])
        let expectation = XCTestExpectation(description: "fetch completion")
        
        sut.fetchUniqueCurrenicesAndPairs { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to empty data")
            case .failure(let error):
                XCTAssertEqual(error as? APIRequestError, APIRequestError.NoData)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchUniqueCurrenicesAndPairsFailureDueToGatewayError() {
        gateway.fetchCurrencyDataResult = .failure(NetworkError.NoIntertnetConnection)
        
        let expectation = XCTestExpectation(description: "fetch completion")
        
        sut.fetchUniqueCurrenicesAndPairs { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to gateway error")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchUniqueCurrenciesAndPairsFailureDueToEmptyResponseMapperConversionResult() {
        let alorPair = getAlorCurrencyPair()
        gateway.fetchCurrencyDataResult = .success([alorPair])
        responseMapper.convertedCurrencyPairs = []
        
        let expectation = XCTestExpectation(description: "fetch completion")
        
        sut.fetchUniqueCurrenicesAndPairs { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to empty response mapper result")
            case .failure(let error):
                XCTAssertEqual(error as? APIRequestError, APIRequestError.NoData)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - sendPurchaseOffer
    func test_sendPurchaseOfferSuccess() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantity = 10.0
        
        gateway.sendPurchaseRequestResult = .success(true)
        
        let expectation = XCTestExpectation(description: "send completion")
        
        sut.sendPurchaseOffer(offer: offer, quantity: quantity) { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertTrue(self.gateway.sendPurchaseRequestCalled)
                XCTAssertNotNil(self.gateway.requestToSend)
            case .failure(let error):
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_sendPurchaseOfferFailure() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantity = 10.0
        
        gateway.sendPurchaseRequestResult = .failure(APIRequestError.ClientError)
        
        let expectation = XCTestExpectation(description: "send completion")
        
        sut.sendPurchaseOffer(offer: offer, quantity: quantity) { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error as? APIRequestError, APIRequestError.ClientError)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - fetchUniqueCurrenicesAndPairsWithCombine
    func test_fetchUniqueCurrenicesAndPairsWithCombineSuccess() {
        let alorPair: AlorCurrencyPair = getAlorCurrencyPair()
        let domainPair = getDomainPair()
        
        gateway.fetchCurrencyDataWithCombinePublisher = Just([alorPair])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        responseMapper.convertedCurrencyPairs = [domainPair]
        
        let expectation = XCTestExpectation(description: "combine fetch")
        
        sut.fetchUniqueCurrenicesAndPairsWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("")
                }
            }, receiveValue: { response in
                XCTAssertEqual(response.currencyPairs.count, 1)
                XCTAssertEqual(response.uniqueCurrencies.count, 2)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchUniqueCurrenicesAndPairsWithCombineFailureDueToEmptyData() {
        gateway.fetchCurrencyDataWithCombinePublisher = Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "combine fetch")
        
        sut.fetchUniqueCurrenicesAndPairsWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? APIRequestError, APIRequestError.NoData)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchUniqueCurrenicesAndPairsWithCombineFailureDueToGatewayError() {
        gateway.fetchCurrencyDataWithCombinePublisher = Fail(error: NetworkError.NoIntertnetConnection)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "combine fetch")
        
        sut.fetchUniqueCurrenicesAndPairsWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchUniqueCurrenicesAndPairsWithCombineFailureDueToGmptyResponseMapperConversionResult() {
        let alorPair: AlorCurrencyPair = getAlorCurrencyPair()
        
        gateway.fetchCurrencyDataWithCombinePublisher = Just([alorPair])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        responseMapper.convertedCurrencyPairs = []
        
        let expectation = XCTestExpectation(description: "combine fetch")
        
        sut.fetchUniqueCurrenicesAndPairsWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? APIRequestError, APIRequestError.NoData)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - sendPurchaseRequestWithCombine
    func test_sendPurchaseOfferWithCombineSuccess() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantity = 10.0
        
        gateway.sendPurchaseRequestWithCombinePublisher = Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "combine send")
        
        sut.sendPurchaseOfferWithCombine(offer: offer, quantity: quantity)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail()
                }
            }, receiveValue: { success in
                XCTAssertTrue(success)
                XCTAssertTrue(self.gateway.sendPurchaseRequestCalled)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_sendPurchaseOfferWithCombineFailure() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantity = 10.0
        
        gateway.sendPurchaseRequestWithCombinePublisher = Fail(error: APIRequestError.ClientError)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "combine send")
        
        sut.sendPurchaseOfferWithCombine(offer: offer, quantity: quantity)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? APIRequestError, APIRequestError.ClientError)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
}

private extension CurrencyFetcherTest {
    func getAlorCurrencyPair() -> AlorCurrencyPair {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let cancellationDate = dateFormatter.date(from: "9999-12-31 23:59:59 +0000")!
        
        return AlorCurrencyPair(
            symbol: "CNYRUBTODTOM",
            shortname: "CNY_TODTOM",
            description: "CNY_TODTOM - СВОП CNY/РУБ",
            exchange: "MOEX",
            market: "CURR",
            cancellation: cancellationDate,
            cfiCode: "MRCXXX",
            type: "FOR",
            currency: "RUB",
            ISIN: nil,
            board: "CETS",
            primary_board: "CETS",
            tradingStatusInfo: "нет торгов или торги закрыты",
            complexProductCategory: "",
            lotsize: 100000.0,
            facevalue: 1.0,
            minstep: 1e-05,
            rating: 7580042073.0,
            marginbuy: 0.0,
            marginsell: 0.0,
            marginrate: 0.0,
            pricestep: 0.0,
            priceMax: 0.01487,
            priceMin: -0.0066,
            theorPrice: 0.0,
            theorPriceLimit: 0.0,
            volatility: 0.0,
            priceMultiplier: 1.0,
            priceShownUnits: 1.0,
            yield: nil,
            tradingStatus: 18
        )
    }
    
    func getDomainPair() -> CurrencyPair {
       return CurrencyPair(
            firstCurrency: RandomlyGeneratedCurrency(id: UUID(), name: "CNY", value: 1, quantity: 100000.0, type: .fiat, isFromNet: true),
            secondCurrency: RandomlyGeneratedCurrency(id: UUID(), name: "RUB", value: 1, quantity: 100000.0, type: .fiat, isFromNet: true),
            exchangeRate: 1
        )
    }
}
