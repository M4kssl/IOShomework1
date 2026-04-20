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
    func createRootViewController() -> UINavigationController {
        let splashScreen = SplashScreenViewController()
       
        let splashScreenNavigationController = UINavigationController(rootViewController: splashScreen)
        return splashScreenNavigationController
    }
}
