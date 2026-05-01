//
//  SessionManager.swift
//  homework4
//
//  Created by Максим  on 30.04.2026.
//

import Foundation

protocol SessionManagerProtocol {
    func beginSession(username: String)
    func endSession()
}

final class SessionManager: SessionManagerProtocol {
    static let shared = SessionManager()
    
    private(set) var currentUserUsername: String?
    
    private init() {}
    
    func beginSession(username: String) {
        currentUserUsername = username
    }
    
    func endSession() {
        currentUserUsername = nil
    }
}
