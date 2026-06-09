//
//  OptimizationAssembly.swift
//  homework4
//
//  Created by Максим  on 07.06.2026.
//

import Foundation
import SwiftUI
import UIKit

final class OptimizationAssembly {
    func assembly() -> UIViewController {
        let feedback = BadCurrencyPairsView()
        let hostingController = UIHostingController(rootView: feedback)
        return hostingController
    }
}
