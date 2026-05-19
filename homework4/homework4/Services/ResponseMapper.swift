//
//  ResponseMapper.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation

protocol AlorResponseMapperProtocol {
    func convertToDomainCurrency(_ serviceCurrency: [AlorCurrencyPair]) -> [CurrencyPair]
}

struct AlorResponseMapper: AlorResponseMapperProtocol {
    func convertToDomainCurrency(_ serviceCurrencies: [AlorCurrencyPair]) -> [CurrencyPair] {
        var result = [CurrencyPair]()
        var currencies = [String : RandomlyGeneratedCurrency]()
        
        for serviceCurrency in serviceCurrencies {
            var newFirstCurrency: RandomlyGeneratedCurrency
            var newSecondCurrency: RandomlyGeneratedCurrency
            
            let secondCurrencyName = serviceCurrency.currency
            let firstCurrencyName = serviceCurrency.symbol.cutFromLeft(uptoPosition: 3) ?? serviceCurrency.symbol
            
            if let firstCurrency = currencies[firstCurrencyName] {
                newFirstCurrency = firstCurrency
            } else {
                newFirstCurrency = RandomlyGeneratedCurrency(
                    id: UUID(),
                    name: firstCurrencyName,
                    value: serviceCurrency.facevalue,
                    quantity: .zero,
                    type: .fiat,
                    isFromNet: true
                )
                currencies[firstCurrencyName] = newFirstCurrency
            }
            
            if let secondCurrency = currencies[secondCurrencyName] {
                newSecondCurrency = secondCurrency
            } else {
                newSecondCurrency = RandomlyGeneratedCurrency(
                    id: UUID(),
                    name: secondCurrencyName,
                    value: serviceCurrency.priceMax,
                    quantity: serviceCurrency.lotsize,
                    type: .fiat,
                    isFromNet: true
                )
                currencies[secondCurrencyName] = newSecondCurrency
            }
            let newPair = CurrencyPair(
                firstCurrency: newFirstCurrency,
                secondCurrency: newSecondCurrency,
                exchangeRate: serviceCurrency.priceMax
            )
            result.append(newPair)
        }
        return result
    }
}

extension String {
    func substringPosition(substring: String) -> Int? {
        if let range = self.range(of: substring) {
            let position = self.distance(from: self.startIndex, to: range.lowerBound)
            return position
        } else {
            return nil
        }
    }
    
    func cutFromLeft(uptoPosition: Int) -> String? {
        if uptoPosition <= self.count {
            let endIndex = self.index(self.startIndex, offsetBy: uptoPosition)
            let result = String(self[..<endIndex])
            return result
        } else {
            return nil
        }
    }
}
