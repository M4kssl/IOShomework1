//
//  AlorRequestMapperMock.swift
//  TradingAppTests
//
//  Created by Максим  on 16.05.2026.
//

import Foundation
@testable import homework4

class AlorRequestMapperMock: AlorRequestMapperProtocol {
    var mappedRequest: AlorPurchaseRequest?
    func mapPurchaseOfferRequest(offer: Offer, quantity: Double) -> AlorPurchaseRequest {
        let request = AlorPurchaseRequest(offer: offer, quantiy: quantity)
        return request
    }
}
