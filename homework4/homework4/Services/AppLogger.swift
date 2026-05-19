//
//  AppLogger.swift
//  homework4
//
//  Created by Максим  on 17.05.2026.
//

import Foundation
import OSLog

struct AppLogger {
    static let subsystem = Bundle.main.bundleIdentifier ?? ""
    
    static let network = Logger(subsystem: AppLogger.subsystem, category: "network")
    static let login = Logger(subsystem: AppLogger.subsystem, category: "login")
    static let trading = Logger(subsystem: AppLogger.subsystem, category: "trading")
}
