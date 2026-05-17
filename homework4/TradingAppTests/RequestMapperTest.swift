//
//  RequestMapperTest.swift
//  TradingAppTests
//
//  Created by Максим  on 17.05.2026.
//

import Foundation
import XCTest
@testable import homework4

final class RequestMapperTest: XCTestCase {
    private var sut: AlorRequestMapper!
    
    override func setUp() {
        super.setUp()
        sut = AlorRequestMapper()
    }
    
    func test_mapPurchaseOfferReques() {
        let currency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        let pair = CurrencyPair(firstCurrency: currency, secondCurrency: currency, exchangeRate: 1.0)
        let offer = Offer(id: UUID(), currencyPair: pair, withDeviation: false)
        let quantityToBuy: Double = 10
        let expectedRequestData = AlorPurchaseRequest(offer: offer, quantiy: quantityToBuy)
        
        let result = sut.mapPurchaseOfferRequest(offer: offer, quantity: quantityToBuy)
        
        XCTAssertEqual(result.offer.id, expectedRequestData.offer.id)
        XCTAssertEqual(result.quantiy, quantityToBuy)
    }
}
