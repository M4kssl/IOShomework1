//
//  UserDefaults.swift
//  homework4
//
//  Created by Максим  on 30.04.2026.
//

import Foundation

final class DefaultsStorageService {
    private let defaults = UserDefaults.standard
    
    var registeredUsers: [String] {
        get {
            guard let usersData = defaults.data(forKey: Keys.registeredUsers) else { return [] }
            do {
                let registeredUsers = try JSONDecoder().decode([String].self, from: usersData)
                return registeredUsers
            } catch {
                return []
            }
        }
        set {
            if let jsonData = try? JSONEncoder().encode(newValue) {
                defaults.set(jsonData, forKey: Keys.registeredUsers)
            }
        }
    }
    
    var loggedUser: String? {
        get {
            guard let username = defaults.string(forKey: Keys.loggedUser) else { return nil }
            return username
        }
        set {
            defaults.set(newValue, forKey: Keys.loggedUser)
        }
    }
}

// MARK: - Keys
private enum Keys {
    static let registeredUsers = "registeredUsers"
    static let loggedUser = "loggedUser"
}
