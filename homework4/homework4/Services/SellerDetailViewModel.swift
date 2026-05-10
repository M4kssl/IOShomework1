//
//  SellerDetailViewModel.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation

final class SellerDetailViewModel {
    private(set) var sellerDetail: SellerDetail
    
    init() {
        let rating = Double.random(in: DefaultValues.ratingRange)
        let completedDeals = Int.random(in: DefaultValues.dealsRange)
        let name = DefaultValues.avalibleNames.randomElement() ?? "User \(DefaultValues.userNumberRange)"
      
        sellerDetail = SellerDetail(name: name, id: UUID(), rating: rating, completedDeals: completedDeals)
    }
}

private extension SellerDetailViewModel {
    enum DefaultValues {
        static let avalibleNames = ["Alex", "John", "Hubert", "Julia", "Sam", "Bob", "Alice"]
        static let ratingRange: ClosedRange<Double> = 1...5
        static let dealsRange: ClosedRange<Int> = 10...1000
        static let userNumberRange: ClosedRange<Int> = 1000...9999
    }
}
