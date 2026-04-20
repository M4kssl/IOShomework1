//
//  ChartDataGenerator.swift
//  homework4
//
//  Created by Максим  on 09.04.2026.
//

import Foundation

protocol ChartDataGeneratorProtocol {
    var candlesticks: [Candlestick] { get }
    func generateCandles(amountOfCandles: Int)
    func getTotalMinMaxPrices() -> (min: Double, max: Double)
    func addRandomizedCandlestick()
}

final class ChartDataGenerator: ChartDataGeneratorProtocol {
    private(set) var candlesticks = [Candlestick]()
    
    func generateCandles(amountOfCandles: Int) {
        candlesticks.removeAll()
        for _ in .zero..<amountOfCandles {
            addRandomizedCandlestick()
        }
    }
    
    func getTotalMinMaxPrices() -> (min: Double, max: Double) {
        var maxPrice: Double = 0
        var minPrice: Double = .infinity
        for candle in candlesticks {
            if candle.minimumPrice < minPrice {
                minPrice = candle.minimumPrice
            }
            if candle.maximumPrice > maxPrice {
                maxPrice = candle.maximumPrice
            }
        }
        return (min: minPrice, max: maxPrice)
    }
    
    func addRandomizedCandlestick() {
        let isOpenPriceUp = Bool.random()
        let isClosePriceUp = Bool.random()
        var lastClosePrice = DefaultValues.startingPrice
        
        if !candlesticks.isEmpty {
            lastClosePrice = candlesticks[candlesticks.endIndex - 1].closePrice
        }
        
        var openPrice: Double
        var closePrice: Double
        var minPrice: Double
        var maxPrice: Double
        
        if isOpenPriceUp {
            openPrice = lastClosePrice + Double.random(in: .zero...DefaultValues.оpenPriceDeviation)
        } else {
            openPrice = lastClosePrice - Double.random(in: .zero...DefaultValues.оpenPriceDeviation)
        }
        
        if isClosePriceUp {
            closePrice = openPrice + Double.random(in: DefaultValues.bodyDeviationRange)
        } else {
            closePrice = openPrice - Double.random(in: DefaultValues.bodyDeviationRange)
        }
        
        let maxPriceDeviation = Double.random(in: DefaultValues.shadowDeviationRange)
        let minPriceDeviation = Double.random(in: DefaultValues.shadowDeviationRange)
        
        maxPrice = isClosePriceUp ? closePrice + maxPriceDeviation : openPrice + maxPriceDeviation
        minPrice = isClosePriceUp ? openPrice - minPriceDeviation : closePrice - maxPriceDeviation
        
        let newCandlestick = Candlestick(
            id: UUID(),
            openPrice: openPrice,
            closePrice: closePrice,
            minimumPrice: minPrice,
            maximumPrice: maxPrice
        )
        candlesticks.append(newCandlestick)
    }
}

// MARK: - Constants
private extension ChartDataGenerator {
    struct DefaultValues {
        static let startingPrice: Double = 1000
        static let оpenPriceDeviation: Double = 1
        static let bodyDeviationRange: ClosedRange<Double> = 3...20
        static let shadowDeviationRange: ClosedRange<Double> = 1...5
    }
}
