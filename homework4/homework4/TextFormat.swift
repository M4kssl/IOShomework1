//
//  TextFormat.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//

import Foundation
import UIKit

struct AppFonts {
    static let headline = UIFont.preferredFont(forTextStyle: .headline)
    static let body = UIFont.preferredFont(forTextStyle: .body)
    static let footnote = UIFont.preferredFont(forTextStyle: .footnote)
    static let title = UIFont.preferredFont(forTextStyle: .largeTitle)
}

extension Double {
    var stringWithTwoDecimalPlaces: String {
        return String(format: "%.2f", self)
    }
}
