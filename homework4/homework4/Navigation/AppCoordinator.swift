//
//  AppCoordinator.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let splashScreenCoordinator = SplashScreenCoordinator(window: window)
        splashScreenCoordinator.onFinishLoading = { [weak self] isLoggedIn in
            self?.removeChildCoordinator(ofType: SplashScreenCoordinator.self)
            if isLoggedIn {
                self?.showMain()
            } else {
                self?.showLogin()
            }
        }
        addChildCoordinator(splashScreenCoordinator)
        splashScreenCoordinator.start()
    }
    
    private func showLogin() {
        let loginCoordinator = LoginCoordinator(window: window)
        loginCoordinator.onLoginSuccess = { [weak self] in
            self?.removeChildCoordinator(ofType: LoginCoordinator.self)
            self?.showMain()
        }
        addChildCoordinator(loginCoordinator)
        loginCoordinator.start()
    }

    private func showMain() {
        let mainCoordinator = MainTabBarCoordinator(window: window)
        mainCoordinator.onLogout = { [weak self] in
            self?.removeChildCoordinator(ofType: MainTabBarCoordinator.self)
            self?.showLogin()
        }
        addChildCoordinator(mainCoordinator)
        mainCoordinator.start()
    }
}
