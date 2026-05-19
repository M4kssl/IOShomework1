//
//  AlorResponseMapperMock.swift
//  TradingAppTests
//
//  Created by Максим  on 16.05.2026.
//

import Foundation
@testable import homework4

class AlorResponseMapperMock: AlorResponseMapperProtocol {
    var convertedCurrencyPairs: [CurrencyPair]?
    
    func convertToDomainCurrency(_ serviceCurrency: [AlorCurrencyPair]) -> [CurrencyPair] {
        return convertedCurrencyPairs ?? []
    }
}
