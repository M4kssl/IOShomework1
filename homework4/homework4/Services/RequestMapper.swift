//
//  RequestMapper.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation

protocol AlorRequestMapperProtocol {
    func mapPurchaseOfferRequest(offer: Offer, quantity: Double) -> AlorPurchaseRequest
}

struct AlorRequestMapper: AlorRequestMapperProtocol {
    func mapPurchaseOfferRequest(offer: Offer, quantity: Double) -> AlorPurchaseRequest {
        return AlorPurchaseRequest(offer: offer, quantiy: quantity)
    }
}
