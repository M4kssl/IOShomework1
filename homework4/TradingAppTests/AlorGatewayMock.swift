//
//  AlorGatewayMock.swift
//  TradingAppTests
//
//  Created by Максим  on 14.05.2026.
//

import Foundation
import Combine
@testable import homework4

final class AlorGatewayMock: AlorGatewayProtocol {
    var fetchCurrencyDataResult: Result<[AlorCurrencyPair]?, Error>?
    var fetchCurrencyDataCalled = false
    var sendPurchaseRequestResult: Result<Bool, Error>?
    var sendPurchaseRequestCalled = false
    var requestToSend: AlorPurchaseRequest?
    var fetchCurrencyDataWithCombinePublisher: AnyPublisher<[AlorCurrencyPair], Error>?
    var sendPurchaseRequestWithCombinePublisher: AnyPublisher<Bool, Error>?
    
    func fetchCurrencyData(completionHandler: @escaping (Result<[AlorCurrencyPair]?, Error>) -> Void) {
        fetchCurrencyDataCalled = true
        if let result = fetchCurrencyDataResult {
            completionHandler(result)
        }
    }
    
    func sendPurchaseRequest(requestData: AlorPurchaseRequest, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        sendPurchaseRequestCalled = true
        requestToSend = requestData
        if let result = sendPurchaseRequestResult {
            completionHandler(result)
        }
    }
    
    func fetchCurrencyDataWithCombine() -> AnyPublisher<[AlorCurrencyPair], Error> {
        fetchCurrencyDataCalled = true
        return fetchCurrencyDataWithCombinePublisher ?? Fail(error: NSError(domain: "Test", code: -1)).eraseToAnyPublisher()
    }
    
    func sendPurchaseRequestWithCombine(requestData: AlorPurchaseRequest) -> AnyPublisher<Bool, Error> {
        sendPurchaseRequestCalled = true
        requestToSend = requestData
        return sendPurchaseRequestWithCombinePublisher ?? Fail(error: NSError(domain: "Test", code: -1)).eraseToAnyPublisher()
    }
}
