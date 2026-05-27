//
//  HeatmapAssembly.swift
//  homework4
//
//  Created by Максим  on 24.05.2026.
//

import UIKit
import SwiftUI

final class HeatmapAssembly {
    func assembly() -> UIViewController {
        let heatmap = Heatmap()
        let hostingController = UIHostingController(rootView: heatmap)
        return hostingController
    }
}
