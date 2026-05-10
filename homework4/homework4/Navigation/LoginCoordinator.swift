//
//  LoginCoordinator.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation
import UIKit

final class LoginCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onLoginSuccess: (() -> Void)?
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let loginViewController = LoginViewController()
        loginViewController.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
