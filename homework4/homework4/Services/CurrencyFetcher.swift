//
//  CurrencyFetcher.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation

protocol CurrencyFetcherProtocol {
    func fetchUiniqueCuurenicesAndPairs(completionHandler: @escaping (Result<CurrencyFetcherResponse, Error>) -> Void)
    func sendPurchaseOffer(offer: Offer, quantity: Double, completionHandler: @escaping (Result<Bool, Error>) -> Void)
}

final class AlorCurrencyFetcher: CurrencyFetcherProtocol {
    let apiClient = AlorAPIClient()
    let requestMapper = AlorRequestMapper()
    
    func fetchUiniqueCuurenicesAndPairs(completionHandler: @escaping (Result<CurrencyFetcherResponse, Error>) -> Void) {
        apiClient.getAllCurrencyPairs { [weak self] result in
            switch result {
            case .success(let newPairs):
                if let newPairs, !newPairs.isEmpty {
                    guard let uniqueCurrencies = self?.getUiqueCurrenciesFromPairs(pairs: newPairs) else {
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
}

private extension AlorCurrencyFetcher {
    func getUiqueCurrenciesFromPairs(pairs: [CurrencyPair]) -> [RandomlyGeneratedCurrency] {
        var uniqueCurrencies = [UUID : RandomlyGeneratedCurrency]()
        
        for pair in pairs {
            uniqueCurrencies[pair.firstCurrency.id] = pair.firstCurrency
            uniqueCurrencies[pair.secondCurrency.id] = pair.secondCurrency
        }
        return Array(uniqueCurrencies.values)
    }
}
