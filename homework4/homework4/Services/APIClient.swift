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
    func sendRequest(request: URLRequest, completionHandler: @escaping (Result<Data?, Error>) -> Void)
    func sendRequestWithCombine(request: URLRequest) -> AnyPublisher<Data, Error>
}

final class AlorAPIClient: APIClientProtocol {
    let responseMapper = AlorResponseMapper()
    let urlSession = URLSession.shared
    
    func sendRequest(request: URLRequest, completionHandler: @escaping (Result<Data?, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            completionHandler(.failure(NetworkError.NoIntertnetConnection))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
            
            completionHandler(.success(data))
            return
        }
        task.resume()
    }
    
    func sendRequestWithCombine(request: URLRequest) -> AnyPublisher<Data, Error> {
        guard NetworkMonitor.shared.isConnected else {
            return Fail(error: NetworkError.NoIntertnetConnection).eraseToAnyPublisher()
        }
        
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
            .eraseToAnyPublisher()
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
