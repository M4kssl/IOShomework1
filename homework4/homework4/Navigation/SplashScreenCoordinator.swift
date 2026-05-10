//
//  SplashScreenCoordinator.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation
import UIKit

final class SplashScreenCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onFinishLoading: ((Bool) -> Void)?
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let splashScreenViewController = SplashScreenViewController()
        splashScreenViewController.onFinishLoading = { [weak self] in
            var isLoggedIn = false
            if let loggedUser = DefaultsStorageService().loggedUser {
                isLoggedIn = true
                SessionManager.shared.beginSession(username: loggedUser)
            }
            self?.onFinishLoading?(isLoggedIn)
        }
        let navigationController = UINavigationController(rootViewController: splashScreenViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
