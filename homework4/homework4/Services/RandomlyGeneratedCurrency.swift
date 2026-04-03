//
//  RandomlyGeneratedCurrency.swift
//  homework4
//
//  Created by Максим  on 31.03.2026.
//

import Foundation

struct RandomlyGeneratedCurrency {
    let id: UUID
    let name: String
    let value: Double
    let type: CurrencyType
    let isChosen: Bool
}

// MARK: - Static Methods
extension RandomlyGeneratedCurrency {
    static func generateRandomNames(quantityOfNames: Int) -> Set<String> {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let length = Int.random(in: 2...4)
        var names = Set<String>()
        
        while names.count < quantityOfNames {
            var name = ""
            for _ in .zero..<length {
                let index = Int.random(in: .zero..<letters.count - 1)
                name += String(letters[index])
            }
            names.insert(name)
        }
        return names
    }
    
    static func generatePlaceholderCurrency() -> RandomlyGeneratedCurrency {
        return RandomlyGeneratedCurrency(
            id: UUID(),
            name: "Choose currency",
            value: 0,
            type: .crypto,
            isChosen: false
        )
    }
}

extension RandomlyGeneratedCurrency {
    var stringToDisplay: String {
        return "\(name) - \(value.stringWithTwoDecimalPlaces)"
    }
}
