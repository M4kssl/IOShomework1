//
//  Candlestick.swift
//  homework4
//
//  Created by Максим  on 08.04.2026.
//

import Foundation

struct Candlestick {
    let id: UUID
    let openPrice: Double
    let closePrice: Double
    let minimumPrice: Double
    let maximumPrice: Double
}

extension Candlestick {
    var minMaxPriceRange: Double {
        return maximumPrice - minimumPrice
    }
    
    var openClosePriceRange: Double {
        return closePrice - openPrice
    }
}
