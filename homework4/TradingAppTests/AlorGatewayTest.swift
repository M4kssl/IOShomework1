//
//  AlorGatewayTest.swift
//  TradingAppTests
//
//  Created by Максим  on 17.05.2026.
//

import Foundation
import XCTest
import Combine
@testable import homework4

final class AlorGatewayTest: XCTestCase {
    private var sut: AlorGateway!
    private var apiClient: APIClientMock!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        apiClient = APIClientMock()
        sut = AlorGateway(apiClient: apiClient)
        
        cancellables = []
    }
    
    // MARK: - fetchCurrencyData
    func test_fetchCurrencyDataSuccess() {
        let expectedData = getJSONData()
        apiClient.sendRequestResult = .success(expectedData)
        
        let expectation = XCTestExpectation(description: "fetchCurrencyData completion")
        
        sut.fetchCurrencyData { result in
            switch result {
            case .success(let pairs):
                XCTAssertNotNil(pairs)
                XCTAssertEqual(pairs?.count, 1)
                XCTAssertEqual(pairs?.first?.symbol, "SBER")
            case .failure(let error):
                XCTFail("")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(apiClient.sendRequestCalled)
        XCTAssertEqual(
            apiClient.capturedRequest?.url?.absoluteString,
            "https://apidev.alor.ru/md/v2/Securities?sector=CURR&format=Simple"
        )
    }
    
    func test_fetchCurrencyDataFaolureDueToEmptyData() {
        apiClient.sendRequestResult = .success(nil)
        let expectation = XCTestExpectation(description: "fetchCurrencyData completion")
        
        sut.fetchCurrencyData { result in
            switch result {
            case .success:
                XCTFail("Expected failure due empty data")
            case .failure(let error):
                XCTAssertEqual(error as? APIRequestError, APIRequestError.NoData)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchCurrencyDataFailureDueToDecodingError() {
        let invalidData = "invalid json".data(using: .utf8)
        apiClient.sendRequestResult = .success(invalidData)
        
        let expectation = XCTestExpectation(description: "fetchCurrencyData completion")
        
        sut.fetchCurrencyData { result in
            switch result {
            case .success:
                XCTFail("Expected decoding error")
            case .failure(let error):
                XCTAssertEqual(error as? APIRequestError, APIRequestError.ClientError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchCurrencyDataFailureDueToNetworkError() {
        apiClient.sendRequestResult = .failure(NetworkError.NoIntertnetConnection)
        
        let expectation = XCTestExpectation(description: "fetchCurrencyData completion")
        
        sut.fetchCurrencyData { result in
            switch result {
            case .success:
                XCTFail("Expected network error")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    
    // MARK: - fetchCurrencyDataWithCombine
    func  test_fetchCurrencyDataWithCombineSuccess() {
        let expectedData = getJSONData()
        apiClient.sendRequestResult = .success(expectedData)
        
        apiClient.sendRequestWithCombinePublisher = Just(expectedData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "fetchCurrencyDataWithCombine completion")
        
        sut.fetchCurrencyDataWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail()
                }
            }, receiveValue: { pairs in
                XCTAssertEqual(pairs.count, 1)
                XCTAssertEqual(pairs.first?.symbol, "SBER")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
        XCTAssertTrue(apiClient.sendRequestCalled)
    }
    
    func test_fetchCurrencyDataWithCombineFailureDueToDecodingError() {
        let invalidData = "invalid".data(using: .utf8)!
        apiClient.sendRequestWithCombinePublisher = Just(invalidData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "fetchCurrencyDataWithCombine completion")
        
        sut.fetchCurrencyDataWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? APIRequestError, APIRequestError.ClientError)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected error")
                }
            }, receiveValue: { _ in
                XCTFail("Expected error")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchCurrencyDataWithCombineFailureDueToNetworkError() {
        let expectation = XCTestExpectation(description: "fetchCurrencyDataWithCombine completion")
        apiClient.sendRequestWithCombinePublisher = Fail(error: NetworkError.NoIntertnetConnection)
            .eraseToAnyPublisher()
        
        sut.fetchCurrencyDataWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? NetworkError, NetworkError.NoIntertnetConnection)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected error")
                }
            }, receiveValue: { _ in
                XCTFail("Expected error")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: sendPurchaseRequest
    func test_sendPurchaseRequest() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantity = 10.0
        let request = AlorPurchaseRequest(offer: offer, quantiy: quantity)
        
        var successCount = 0
        var failureCount = 0
        let iterations = 50
        
        apiClient.sendRequestResult = .failure(APIRequestError.WrongURL)
        
        let group = DispatchGroup()
        
        for _ in 0..<iterations {
            group.enter()
            sut.sendPurchaseRequest(requestData: request) { result in
                if case .success = result {
                    successCount += 1
                } else {
                    failureCount += 1
                }
                group.leave()
            }
        }
        
        group.wait(timeout: .now() + 5)
        
        XCTAssertGreaterThan(successCount, 0)
        XCTAssertGreaterThan(failureCount, 0)
    }
    
    // MARK: sendPurchaseRequestWithCombine
    func test_sendPurchaseRequestWithCombine() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantity = 10.0
        let request = AlorPurchaseRequest(offer: offer, quantiy: quantity)
        
        var successCount = 0
        var failureCount = 0
        let iterations = 50
        
        apiClient.sendRequestWithCombinePublisher = Fail(error: APIRequestError.WrongURL)
            .eraseToAnyPublisher()
        
        let group = DispatchGroup()
        
        for _ in 0..<iterations {
            group.enter()
            sut.sendPurchaseRequestWithCombine(requestData: request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        failureCount += 1
                    }
                }, receiveValue: { success in
                    XCTAssertTrue(success)
                    successCount += 1
                })
                .store(in: &cancellables)
        }
        
        group.wait(timeout: .now() + 5)
        
        XCTAssertGreaterThan(successCount, 0)
        XCTAssertGreaterThan(failureCount, 0)
    }
}

private extension AlorGatewayTest {
    func getJSONData() -> Data {
        let jsonData =
        """
          [
            {
              "symbol": "SBER",
              "shortname": "Сбербанк",
              "description": "Сбербанк России ПАО ао",
              "exchange": "MOEX",
              "market": "FOND",
              "type": "CS",
              "lotsize": 10,
              "facevalue": 5,
              "cfiCode": "ESXXXX",
              "cancellation": "2020-06-16T23:59:59.9990000Z",
              "minstep": 0.01,
              "rating": 195613886,
              "marginbuy": 6707.86,
              "marginsell": 6707.86,
              "marginrate": 89.3428,
              "pricestep": 6.30202,
              "priceMax": 176.02,
              "priceMin": 170.33,
              "theorPrice": 0,
              "theorPriceLimit": 0,
              "volatility": 0,
              "currency": "RUB",
              "ISIN": "RU000A1014L8",
              "yield": null,
              "board": "TQBR",
              "primary_board": "TQBR",
              "tradingStatus": 17,
              "tradingStatusInfo": "нормальный период торгов",
              "complexProductCategory": "2",
              "priceMultiplier": 1,
              "priceShownUnits": 1,
              "strikePrice": 12000,
              "endExpiration": "2024-03-20T00:00:00.0000000",
              "fixedSpotDiscount": 0,
              "projectedSpotDiscount": 0,
              "underlyingSymbol": "VB12000BC4",
              "optionSide": "Call"
            }
          ]
        """
        return Data(jsonData.utf8)
    }
}
