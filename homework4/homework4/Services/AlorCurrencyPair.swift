//
//  ServiceCurrencyPair.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation

struct AlorCurrencyPair: Decodable {
    let symbol: String
    let shortname: String
    let description: String
    let exchange: String
    let market: String
    let cancellation: Date
    let cfiCode: String
    let type: String
    let currency: String
    let ISIN: String?
    let board: String
    let primary_board: String
    let tradingStatusInfo: String
    let complexProductCategory: String
    let lotsize: Double
    let facevalue: Double
    let minstep: Double
    let rating: Double
    let marginbuy: Double
    let marginsell: Double
    let marginrate: Double
    let pricestep: Double
    let priceMax: Double
    let priceMin: Double
    let theorPrice: Double
    let theorPriceLimit: Double
    let volatility: Double
    let priceMultiplier: Double
    let priceShownUnits: Double
    let yield: Double?
    let tradingStatus: Int32
}
