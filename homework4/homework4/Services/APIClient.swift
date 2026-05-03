//
//  APIClient.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//
import Network
import Foundation
import Combine

protocol APIClientProtocol {
    func getAllCurrencyPairs(completionHandler: @escaping (Result<[CurrencyPair]?, Error>) -> Void)
    func sendPurchaseOffer(requestData: AlorPurchaseRequest, completionHandler: @escaping (Result<Bool, Error>) -> Void)
}

final class AlorAPIClient: APIClientProtocol {
    let responseMapper = AlorResponseMapper()
    let urlSession = URLSession.shared
    
    func getAllCurrencyPairs(completionHandler: @escaping (Result<[CurrencyPair]?, Error>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completionHandler(.failure(NetworkError.NoIntertnetConnection))
            return
        }
        
        guard let url = URL(string: "https://apidev.alor.ru/md/v2/Securities?sector=CURR&format=Simple") else {
            completionHandler(.failure(APIRequestError.WrongURL))
            return
        }
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error {
                completionHandler(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let clientErrorCodeRange = 400...499
                if clientErrorCodeRange.contains(httpResponse.statusCode) {
                    completionHandler(.failure(APIRequestError.ClientError))
                }
            }
            
            guard let data else {
                completionHandler(.failure(APIRequestError.NoData))
                return
            }
            
            do {
                let decoder = self?.configureJSONDecoder() ?? JSONDecoder()
                
                let serviceDataArray = try decoder.decode([AlorCurrencyPair].self, from: data)
                let currencies = self?.responseMapper.convertToDomainCurrency(serviceDataArray)
                completionHandler(.success(currencies))
            } catch {
                completionHandler(.failure(APIRequestError.ClientError))
            }
        }
        task.resume()
    }
    
    func sendPurchaseOffer(requestData: AlorPurchaseRequest, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            completionHandler(.failure(NetworkError.NoIntertnetConnection))
            return
        }
        
        let isSuccessfull = Bool.random()
        if isSuccessfull {
            completionHandler(.success(isSuccessfull))
        } else {
            guard let wongUrl = URL(string: "https://apidev.alorasdfghjkl;.ru/md/v2/Securities?sector=CURR&format=Simple") else {
                completionHandler(.failure(APIRequestError.WrongURL))
                return
            }
            
            var request = URLRequest(url: wongUrl,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                completionHandler(.failure(APIRequestError.WrongURL))
                return
            }
            task.resume()
        }
    }
    
    func getAllCurrencyPairsWithCombine() -> AnyPublisher<[CurrencyPair]?, Error> {
        guard NetworkMonitor.shared.isConnected else {
            return Fail(error: NetworkError.NoIntertnetConnection).eraseToAnyPublisher()
        }
        guard let url = URL(string: "https://apidev.alor.ru/md/v2/Securities?sector=CURR&format=Simple") else {
            return Fail(error: APIRequestError.WrongURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let decoder = configureJSONDecoder()
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    let clientErrorCodeRange = 400...499
                    if clientErrorCodeRange.contains(httpResponse.statusCode) {
                        throw APIRequestError.ClientError
                    }
                }
                return data
            }
            .decode(type: [AlorCurrencyPair].self, decoder: decoder)
            .mapError { error in
                (error is DecodingError) ? APIRequestError.ClientError : error
            }
            .map { [weak self] serviceDataArray in
                self?.responseMapper.convertToDomainCurrency(serviceDataArray)
            }
            .eraseToAnyPublisher()
    }
    
    func sendPurchaseOfferWithCombine(requestData: AlorPurchaseRequest) -> AnyPublisher<Bool, Error> {
        guard NetworkMonitor.shared.isConnected else {
            return Fail(error: NetworkError.NoIntertnetConnection).eraseToAnyPublisher()
        }
        
        let isSuccessfull = Bool.random()
        if isSuccessfull {
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            guard let wongUrl = URL(string: "https://apidev.alorasdfghjkl;.rpv9y8welichkn2/Securities?sector=CURR&format=Simple") else {
                return Fail(error: APIRequestError.WrongURL).eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: wongUrl,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { _ in
                    throw APIRequestError.WrongURL
                }
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Private Methods
private extension AlorAPIClient {
    func configureJSONDecoder() -> JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
}

// MARK: - APIRequestError
enum APIRequestError: Error {
    case WrongURL
    case MappingError
    case NoData
    case DecocingError
    case ClientError
}
