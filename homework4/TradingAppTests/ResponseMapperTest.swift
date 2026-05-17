//
//  ResponseMapperTest.swift
//  TradingAppTests
//
//  Created by Максим  on 17.05.2026.
//

import Foundation
import XCTest
@testable import homework4

final class ResponseMapperTest : XCTestCase {
    private var sut: AlorResponseMapper!
    
    override func setUp() {
        super .setUp()
        sut = AlorResponseMapper()
    }
    
    func test_convertToDomainCurrencyWhenAlorPairsAreNotEmpty() {
        let alorPair = getAlorCurrencyPair()
        let expectedFirstCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "CNY",
            value: 1,
            quantity: .zero,
            type: .fiat,
            isChosen: false,
            isFavorited: false,
            isFromNet: true
        )
        
        let expectedSecondCurrency = RandomlyGeneratedCurrency(
            id: UUID(),
            name: "RUB",
            value: 0.01487,
            quantity: 100000.0,
            type: .fiat,
            isChosen: false,
            isFavorited: false,
            isFromNet: true
        )
        
        let result = sut.convertToDomainCurrency([alorPair])
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].firstCurrency.name, expectedFirstCurrency.name)
        XCTAssertEqual(result[0].secondCurrency.name, expectedSecondCurrency.name)
    }
    
    func test_test_convertToDomainCurrencyWhenAlorPairsAreEmpty() {
        let result = sut.convertToDomainCurrency([])
        XCTAssertTrue(result.isEmpty)
    }
}

private extension ResponseMapperTest {
    func getAlorCurrencyPair() -> AlorCurrencyPair {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let cancellationDate = dateFormatter.date(from: "9999-12-31 23:59:59 +0000")!
        
        return AlorCurrencyPair(
            symbol: "CNYRUBTODTOM",
            shortname: "CNY_TODTOM",
            description: "CNY_TODTOM - СВОП CNY/РУБ",
            exchange: "MOEX",
            market: "CURR",
            cancellation: cancellationDate,
            cfiCode: "MRCXXX",
            type: "FOR",
            currency: "RUB",
            ISIN: nil,
            board: "CETS",
            primary_board: "CETS",
            tradingStatusInfo: "нет торгов или торги закрыты",
            complexProductCategory: "",
            lotsize: 100000.0,
            facevalue: 1.0,
            minstep: 1e-05,
            rating: 7580042073.0,
            marginbuy: 0.0,
            marginsell: 0.0,
            marginrate: 0.0,
            pricestep: 0.0,
            priceMax: 0.01487,
            priceMin: -0.0066,
            theorPrice: 0.0,
            theorPriceLimit: 0.0,
            volatility: 0.0,
            priceMultiplier: 1.0,
            priceShownUnits: 1.0,
            yield: nil,
            tradingStatus: 18
        )
    }
}
