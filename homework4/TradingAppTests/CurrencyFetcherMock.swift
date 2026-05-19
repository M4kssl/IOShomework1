//
//  CurrencyFetcherMock.swift
//  TradingAppTests
//
//  Created by Максим  on 14.05.2026.
//

import Foundation
import Combine
@testable import homework4

final class CurrencyFetcherMock: CurrencyFetcherProtocol {
    var fetchResult: Result<CurrencyFetcherResponse, Error>?
    var purchaseResult: Result<Bool, Error>?
    var fetchCombineResult: AnyPublisher<CurrencyFetcherResponse, Error>?
    var purchaseCombineResult: AnyPublisher<Bool, Error>?
    var didCallSendPurchaseOffer = false
    var didCallSendPurchaseOfferWithCombine = false
    var didSendPurchaseOffer = false
    
    func fetchUniqueCurrenicesAndPairs(completionHandler: @escaping (Result<CurrencyFetcherResponse, Error>) -> Void) {
        if let result = fetchResult {
            completionHandler(result)
        }
    }
    
    func sendPurchaseOffer(offer: Offer, quantity: Double, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        didCallSendPurchaseOffer = true
        if let result = purchaseResult {
            completionHandler(result)
        }
    }
    
    func fetchUniqueCurrenicesAndPairsWithCombine() -> AnyPublisher<CurrencyFetcherResponse, Error> {
        return fetchCombineResult ?? Fail(error: NSError(domain: "Mock", code: -1)).eraseToAnyPublisher()
    }
    
    func sendPurchaseOfferWithCombine(offer: Offer, quantity: Double) -> AnyPublisher<Bool, Error> {
        didCallSendPurchaseOfferWithCombine = true
        return purchaseCombineResult ?? Just(false).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
