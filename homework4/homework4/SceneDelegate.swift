//
//  SceneDelegate.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createRootViewController()
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func createRootViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
        let botViewController = BotViewController()
        
        botViewController.tabBarItem = UITabBarItem(title: "Bot", image: UIImage(systemName: "brain"), tag: 0)
        botViewController.title = "Bot"
        let botNavigationController = UINavigationController(rootViewController: botViewController)
        tabBarController.viewControllers = [botNavigationController]
        return tabBarController
    }
}
