//
//  MainTabBarCoordinator.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation
import UIKit

final class MainTabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let tabBarController = UITabBarController()
        
        let botNavigationController = UINavigationController()
        let botCoordinator = BotCoordinator(navigationController: botNavigationController)
        childCoordinators.append(botCoordinator)
        botCoordinator.start()
        botNavigationController.tabBarItem = UITabBarItem(title: "Bot", image: UIImage(systemName: "brain"), tag: 0)
        
        let tradingNavigationController = UINavigationController()
        let tradingCoordinator = TradingCoordinator(navigationController: tradingNavigationController)
        childCoordinators.append(tradingCoordinator)
        tradingCoordinator.start()
        tradingNavigationController.tabBarItem = UITabBarItem(
            title: "Trading",
            image: UIImage(systemName: "bitcoinsign.bank.building"),
            tag: 1
        )
        
        let settingsNavigationController = UINavigationController()
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNavigationController)
        settingsCoordinator.onLogout = { [weak self] in
            self?.onLogout?()
        }
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()
        settingsNavigationController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            tag: 2
        )
        
        tabBarController.viewControllers = [botNavigationController, tradingNavigationController, settingsNavigationController]
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
