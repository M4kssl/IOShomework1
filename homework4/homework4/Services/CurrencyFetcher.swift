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
    let gateway: AlorGatewayProtocol
    let requestMapper: AlorRequestMapperProtocol
    let responseMapper: AlorResponseMapperProtocol
    
    init(gateway: AlorGatewayProtocol, requestMapper: AlorRequestMapperProtocol, responseMapper: AlorResponseMapperProtocol) {
        self.gateway = gateway
        self.requestMapper = requestMapper
        self.responseMapper = responseMapper
    }
    
    func fetchUniqueCurrenicesAndPairs(completionHandler: @escaping (Result<CurrencyFetcherResponse, Error>) -> Void) {
        gateway.fetchCurrencyData { [weak self] result in
            switch result {
            case .success(let alorPairs):
                if let alorPairs, !alorPairs.isEmpty {
                    guard let domainPairs = self?.responseMapper.convertToDomainCurrency(alorPairs), !domainPairs.isEmpty else {
                        completionHandler(.failure(APIRequestError.NoData))
                        return
                    }
                    guard let uniqueCurrencies = self?.getUniqueCurrenciesFromPairs(pairs: domainPairs) else {
                        completionHandler(.failure(APIRequestError.NoData))
                        return
                    }
                    let result = CurrencyFetcherResponse(uniqueCurrencies: uniqueCurrencies, currencyPairs: domainPairs)
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
        gateway.sendPurchaseRequest(requestData: requestData) { result in
            switch result {
            case .success(let result):
                completionHandler(.success(result))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchUniqueCurrenicesAndPairsWithCombine() -> AnyPublisher<CurrencyFetcherResponse, Error> {
        return gateway.fetchCurrencyDataWithCombine()
            .tryMap { [weak self] alorPairs -> CurrencyFetcherResponse in
                guard !alorPairs.isEmpty else { throw APIRequestError.NoData }
                guard let domainPairs = self?.responseMapper.convertToDomainCurrency(alorPairs), !domainPairs.isEmpty else {
                    throw APIRequestError.NoData
                }
                guard let uniqueCurrencies = self?.getUniqueCurrenciesFromPairs(pairs: domainPairs) else {
                    throw APIRequestError.NoData
                }
                return CurrencyFetcherResponse(uniqueCurrencies: uniqueCurrencies, currencyPairs: domainPairs)
            }
            .eraseToAnyPublisher()
    }
    
    func sendPurchaseOfferWithCombine(offer: Offer, quantity: Double) -> AnyPublisher<Bool, Error> {
        let requestData = requestMapper.mapPurchaseOfferRequest(offer: offer, quantity: quantity)
        
        return gateway.sendPurchaseRequestWithCombine(requestData: requestData)
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
