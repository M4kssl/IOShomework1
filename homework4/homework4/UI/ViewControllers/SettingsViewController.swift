//
//  SettingsViewController.swift
//  homework4
//
//  Created by Максим  on 30.04.2026.
//

import Foundation
import UIKit

final class SettingsViewController: UIViewController {
    private let keychain = Keychain()
    private let defaultsStorage = DefaultsStorageService()
    
    private let logOutButton: UIButton = {
        $0.layer.backgroundColor = UIColor.systemBlue.cgColor
        $0.layer.borderWidth = BorderWidth.standard
        $0.layer.cornerRadius = CornerRadius.small
        $0.setTitle(.logOutButton, for: .normal)
        return $0
    } (UIButton())
    
    var onLogout: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupUI()
        setConstraints()
    }
}

// MARK: Private Methods
private extension SettingsViewController {
    func addSubviews() {
        view.addSubview(logOutButton)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.systemYellow
        setupLogOutButton()
    }
    
    func setConstraints() {
        setLogOutButtonConstraints()
    }
    
    func setupLogOutButton() {
        logOutButton.addTarget(self, action: #selector(handleLogOutButtonTap), for: .touchUpInside)
    }
    
    func setLogOutButtonConstraints() {
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logOutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -ConstraintSpacing.extraLarge),
            logOutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.large),
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.large)
        ])
    }
}

// MARK: - Action Handlers
private extension SettingsViewController {
    @objc
    func handleLogOutButtonTap() {
       onLogout?()
    }
}

// MARK: - Routing
private extension SettingsViewController {
    func routeToLoginScreen() {
        if let parentNavigationController = self.tabBarController?.navigationController {
            let loginViewController = LoginViewController()
            parentNavigationController.popToRootViewController(animated: false)
            parentNavigationController.replaceRootViewController(with: loginViewController)
        }
    }
}

// MARK: - String Constants
private extension String {
    static let logOutButton = "LogOut"
}
