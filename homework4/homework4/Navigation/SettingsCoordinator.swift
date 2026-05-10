//
//  SettingsCoordinator.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation
import UIKit

final class SettingsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let settingsViewController = SettingsViewController()
        settingsViewController.title = "Settings"
        
        settingsViewController.onLogout = { [weak self] in
            DefaultsStorageService().loggedUser = nil
            SessionManager.shared.endSession()
            self?.onLogout?()
        }
        navigationController.pushViewController(settingsViewController, animated: false)
    }
}
