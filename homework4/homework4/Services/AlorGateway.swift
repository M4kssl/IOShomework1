//
//  AlorGateway.swift
//  homework4
//
//  Created by Максим  on 10.05.2026.
//

import Foundation
import Combine

protocol AlorGatewayProtocol {
    func fetchCurrencyData(completionHandler: @escaping (Result<[AlorCurrencyPair]?, Error>) -> Void)
    func sendPurchaseRequest(requestData: AlorPurchaseRequest, completionHandler: @escaping (Result<Bool, Error>) -> Void)
    func fetchCurrencyDataWithCombine() -> AnyPublisher<[AlorCurrencyPair], Error>
    func sendPurchaseRequestWithCombine(requestData: AlorPurchaseRequest) -> AnyPublisher<Bool, Error>
}


final class AlorGateway: AlorGatewayProtocol {
    let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchCurrencyData(completionHandler: @escaping (Result<[AlorCurrencyPair]?, Error>) -> Void) {
        AppLogger.network.info("Gateway started configuring url request to fetch currency data")
        guard let url = URL(string: "https://apidev.alor.ru/md/v2/Securities?sector=CURR&format=Simple") else {
            AppLogger.network.error("Gateway failed due to wrong url")
            completionHandler(.failure(APIRequestError.WrongURL))
            return
        }
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        apiClient.sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let data else {
                    completionHandler(.failure(APIRequestError.NoData))
                    return
                }
                do {
                    let decoder = self?.configureJSONDecoder() ?? JSONDecoder()
                    let serviceDataArray = try decoder.decode([AlorCurrencyPair].self, from: data)
                    completionHandler(.success(serviceDataArray))
                    AppLogger.network.info("Gateway successfully finished fetching currency data")
                } catch {
                    AppLogger.network.error("Gateway failed to decode currency data, error - \(error)")
                    completionHandler(.failure(APIRequestError.ClientError))
                }
            case .failure(let error):
                AppLogger.network.error("Gateway failed due to an unexpected error - \(error)")
                completionHandler(.failure(error))
            }
        }
    }
    
    func sendPurchaseRequest(requestData: AlorPurchaseRequest, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        AppLogger.network.info("Gateway started configuring url request to send purchase offer for \(requestData.offer.id)")
        let isSuccessfull = Bool.random()
        if isSuccessfull {
            AppLogger.network.info("Gateway successfully sent purchase offer for \(requestData.offer.id)")
            completionHandler(.success(isSuccessfull))
        } else {
            guard let wrongUrl = URL(string: "htt543wysu6drytkfuygliuhnlor=mhgvSimple") else {
                AppLogger.network.error("Gateway failed due to wrong url")
                completionHandler(.failure(APIRequestError.WrongURL))
                return
            }
            let request = URLRequest(url: wrongUrl, timeoutInterval: Double.infinity)
            
            apiClient.sendRequest(request: request) { result in
                switch result {
                case .success(let data):
                    AppLogger.network.info("Gateway successfully sent purchase offer for \(requestData.offer.id)")
                    completionHandler(.success(true))
                case .failure(let error):
                    AppLogger.network.error("Gateway failed due to wrong url")
                    completionHandler(.failure(error))
                }
                
            }
        }
    }
    
    func fetchCurrencyDataWithCombine() -> AnyPublisher<[AlorCurrencyPair], Error> {
        AppLogger.network.info("Started configuring url request to fetch currency data with combine")
        guard let url = URL(string: "https://apidev.alor.ru/md/v2/Securities?sector=CURR&format=Simple") else {
            AppLogger.network.error("Gateway failed due to wrong url")
            return Fail(error: APIRequestError.WrongURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let decoder = configureJSONDecoder()
        
        return apiClient.sendRequestWithCombine(request: request)
            .decode(type: [AlorCurrencyPair].self, decoder: decoder)
            .mapError { error in
                
                (error is DecodingError) ? APIRequestError.ClientError : error
            }.eraseToAnyPublisher()
    }
    
    func sendPurchaseRequestWithCombine(requestData: AlorPurchaseRequest) -> AnyPublisher<Bool, Error> {
        AppLogger.network.info("Gateway started configuring url request to send purchase offer with combine for \(requestData.offer.id)")
        let isSuccessfull = Bool.random()
        if isSuccessfull {
            AppLogger.network.info("Gateway successfully sent purchase offer for \(requestData.offer.id)")
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            guard let wrongUrl = URL(string: "htt543wysu6drytkfuygliuhnlor=mhgvSimple") else {
                AppLogger.network.error("Gateway failed due to wrong url")
                return Fail(error: APIRequestError.WrongURL).eraseToAnyPublisher()
            }
            var request = URLRequest(url: wrongUrl,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"
            
            return apiClient.sendRequestWithCombine(request: request)
                .tryMap { _ in
                    AppLogger.network.error("Gateway failed due to wrong url")
                    throw APIRequestError.WrongURL
                }.eraseToAnyPublisher()
        }
    }
}

// MARK: - Private Methods
private extension AlorGateway {
    func configureJSONDecoder() -> JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
}
