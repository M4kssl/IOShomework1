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
        
        loginViewController.onCantLogInTapped = { [weak self] in
            guard let self else { return }
            routeToFeedbackScreen()
        }
    }
}

private extension LoginCoordinator {
    func routeToFeedbackScreen() {
        let feedbackViewController = FeedbackAssembly(onDismiss: { [weak self] in
            self?.window.rootViewController?.dismiss(animated: true)
        }).assembly()
        window.rootViewController?.present(feedbackViewController, animated: true)
    }
}
