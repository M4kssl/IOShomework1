//
//  CurrencyFetcher.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation
import Combine

protocol CurrencyFetcherProtocol {
    func fetchUniqueCurrenicesAndPairs(completionHandler: @escaping (Result<CurrencyFetcherResponse, Error>) -> Void)
    func sendPurchaseOffer(offer: Offer, quantity: Double, completionHandler: @escaping (Result<Bool, Error>) -> Void)
    func fetchUniqueCurrenicesAndPairsWithCombine() -> AnyPublisher<CurrencyFetcherResponse, Error>
    func sendPurchaseOfferWithCombine(offer: Offer, quantity: Double) -> AnyPublisher<Bool, Error>
}

final class AlorCurrencyFetcher: CurrencyFetcherProtocol {
    let apiClient = AlorAPIClient()
    let requestMapper = AlorRequestMapper()
    
    func fetchUniqueCurrenicesAndPairs(completionHandler: @escaping (Result<CurrencyFetcherResponse, Error>) -> Void) {
        apiClient.getAllCurrencyPairs { [weak self] result in
            switch result {
            case .success(let newPairs):
                if let newPairs, !newPairs.isEmpty {
                    guard let uniqueCurrencies = self?.getUniqueCurrenciesFromPairs(pairs: newPairs) else {
                        completionHandler(.failure(APIRequestError.NoData))
                        return
                    }
                    let result = CurrencyFetcherResponse(uniqueCurrencies: uniqueCurrencies, currencyPairs: newPairs)
                    completionHandler(.success(result))
                } else {
                    completionHandler(.failure(APIRequestError.NoData))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func sendPurchaseOffer(offer: Offer, quantity: Double, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        let requestData = requestMapper.mapPurchaseOfferRequest(offer: offer, quantity: quantity)
        apiClient.sendPurchaseOffer(requestData: requestData) { result in
            switch result {
            case .success(let result):
                completionHandler(.success(result))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchUniqueCurrenicesAndPairsWithCombine() -> AnyPublisher<CurrencyFetcherResponse, Error> {
        return apiClient.getAllCurrencyPairsWithCombine()
            .tryMap { [weak self] newPairs -> CurrencyFetcherResponse in
                guard let newPairs, !newPairs.isEmpty else { throw APIRequestError.NoData }
                guard let uniqueCurrencies = self?.getUniqueCurrenciesFromPairs(pairs: newPairs) else {
                    throw APIRequestError.NoData
                }
                return CurrencyFetcherResponse(uniqueCurrencies: uniqueCurrencies, currencyPairs: newPairs)
            }
            .eraseToAnyPublisher()
    }
    
    func sendPurchaseOfferWithCombine(offer: Offer, quantity: Double) -> AnyPublisher<Bool, Error> {
        let requestData = requestMapper.mapPurchaseOfferRequest(offer: offer, quantity: quantity)
        
        return apiClient.sendPurchaseOfferWithCombine(requestData: requestData)
            .map { result -> Bool in
                return result
            }
            .eraseToAnyPublisher()
    }
}

private extension AlorCurrencyFetcher {
    func getUniqueCurrenciesFromPairs(pairs: [CurrencyPair]) -> [RandomlyGeneratedCurrency] {
        var uniqueCurrencies = [UUID : RandomlyGeneratedCurrency]()
        
        for pair in pairs {
            uniqueCurrencies[pair.firstCurrency.id] = pair.firstCurrency
            uniqueCurrencies[pair.secondCurrency.id] = pair.secondCurrency
        }
        return Array(uniqueCurrencies.values)
    }
}
