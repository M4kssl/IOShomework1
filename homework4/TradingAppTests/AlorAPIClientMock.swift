//
//  AlorAPIClientMock.swift
//  TradingAppTests
//
//  Created by Максим  on 14.05.2026.
//

import Foundation
import Combine
@testable import homework4

final class APIClientMock: APIClientProtocol {
    var sendRequestResult: Result<Data?, Error>?
    var sendRequestCalled = false
    var capturedRequest: URLRequest?
    var requestShouldFail: Bool = false
    var sendRequestWithCombinePublisher: AnyPublisher<Data, Error>?
    
    func sendRequest(request: URLRequest, completionHandler: @escaping (Result<Data?, Error>) -> Void) {
        sendRequestCalled = true
        capturedRequest = request
        if requestShouldFail {
        }
        if let result = sendRequestResult {
            completionHandler(result)
        }
    }
    
    func sendRequestWithCombine(request: URLRequest) -> AnyPublisher<Data, Error> {
        sendRequestCalled = true
        capturedRequest = request
        return sendRequestWithCombinePublisher ?? Fail(error: NSError(domain: "Test", code: -1)).eraseToAnyPublisher()
    }
}
