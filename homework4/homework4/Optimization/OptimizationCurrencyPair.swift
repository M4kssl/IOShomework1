//
//  OptimizationCurrencyPair.swift
//  homework4
//
//  Created by Максим  on 11.06.2026.
//

import Foundation

struct OptimizationCurrencyPair: Identifiable, Equatable {
    let id: UUID
    let name: String
    var value: Double
    var previousValue: Double
    var history: [Double]
    
    var changePercent: Double {
        guard previousValue != 0 else { return 0 }
        return (value - previousValue) / previousValue * 100
    }
}
