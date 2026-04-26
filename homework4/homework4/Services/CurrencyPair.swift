//
//  CurrencyPair.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation

struct CurrencyPair {
    let firstCurrency: RandomlyGeneratedCurrency
    let secondCurrency: RandomlyGeneratedCurrency
    let exchangeRate: Double
    
    init(firstCurrency: RandomlyGeneratedCurrency, secondCurrency: RandomlyGeneratedCurrency, exchangeRate: Double = 0) {
        self.firstCurrency = firstCurrency
        self.secondCurrency = secondCurrency
        self.exchangeRate = exchangeRate
    }
}
