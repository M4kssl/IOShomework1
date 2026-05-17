//
//  TradingServiceDelegateMock.swift
//  TradingAppTests
//
//  Created by Максим  on 15.05.2026.
//

import Foundation
@testable import homework4

final class TradingServiceDelegateMock: TradingServiceDelegate {
    var handleErrorCalled = false
    var handleErrorHandler: ((Error) -> Void)?
    var offersUpdatedCalled = false
    var offersUpdatedHandler: (() -> Void)?
    
    func handleOperationError(error: Error) {
        handleErrorCalled = true
        handleErrorHandler?(error)
    }
    
    func offersUpdated() {
        offersUpdatedCalled = true
        offersUpdatedHandler?()
    }
}
