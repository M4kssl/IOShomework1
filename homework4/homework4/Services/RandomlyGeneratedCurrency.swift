//
//  RandomlyGeneratedCurrency.swift
//  homework4
//
//  Created by Максим  on 31.03.2026.
//

import Foundation

enum CurrencyType: String, CaseIterable {
    case fiat
    case crypto
}

struct RandomlyGeneratedCurrency {
    let id: UUID
    let name: String
    let value: Double
    let quantity: Double
    let type: CurrencyType
    let isChosen: Bool
    let isFavorited: Bool
    let isFromNet: Bool
}

// MARK: - Static Methods
extension RandomlyGeneratedCurrency {
    init(id: UUID, name: String, value: Double, quantity: Double, type: CurrencyType, isFromNet: Bool){
        self.id = id
        self.name = name
        self.value = value
        self.quantity = quantity
        self.type = type
        self.isChosen = false
        self.isFavorited = false
        self.isFromNet = isFromNet
    }
    
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
            id: UUID.empty,
            name: "Choose currency",
            value: 0,
            quantity: 0,
            type: .crypto,
            isFromNet: false
        )
    }
}

extension RandomlyGeneratedCurrency {
    var stringToDisplay: String {
        return "\(name) - \(value.stringWithTwoDecimalPlaces)"
    }
}

extension RandomlyGeneratedCurrency {
    static func changeQuanityForCurrency(currency: RandomlyGeneratedCurrency, newQuantity: Double) -> RandomlyGeneratedCurrency {
        return RandomlyGeneratedCurrency(
            id: currency.id,
            name: currency.name,
            value: currency.value,
            quantity: newQuantity,
            type: currency.type,
            isChosen: currency.isChosen,
            isFavorited: currency.isFavorited,
            isFromNet: currency.isFromNet
        )
    }
    
    static func changeValueForCurrency(currency: RandomlyGeneratedCurrency, newValue: Double) -> RandomlyGeneratedCurrency {
        return RandomlyGeneratedCurrency(
            id: currency.id,
            name: currency.name,
            value: newValue,
            quantity: currency.quantity,
            type: currency.type,
            isChosen: currency.isChosen,
            isFavorited: currency.isFavorited,
            isFromNet: currency.isFromNet
        )
    }
}

extension UUID {
    static let empty = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}
