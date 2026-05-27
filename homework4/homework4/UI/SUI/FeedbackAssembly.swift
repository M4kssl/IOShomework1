//
//  FeedbackAssembly.swift
//  homework4
//
//  Created by Максим  on 25.05.2026.
//

import Foundation
import SwiftUI
import UIKit

final class FeedbackAssembly {
    private let onDismiss: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    func assembly() -> UIViewController {
        let feedback = Feedback(onDismiss: onDismiss)
        let hostingController = UIHostingController(rootView: feedback)
        return hostingController
    }
}
