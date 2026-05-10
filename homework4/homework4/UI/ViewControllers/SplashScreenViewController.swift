//
//  SplashScreenViewController.swift
//  homework4
//
//  Created by Максим  on 16.04.2026.
//

import Foundation
import UIKit

final class SplashScreenViewController: UIViewController {
    private let emojiLabel: UILabel = {
        $0.text = "🤑"
        $0.font = .systemFont(ofSize: 104)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        return $0
    } (UILabel())
    
    private let loadongLabel: UILabel = {
        $0.text = "Loading..."
        $0.font = AppFonts.footnote
        $0.sizeToFit()
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    } (UILabel())
    
    private var timer: Timer?
    
    var onFinishLoading: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initTimer()
        animateLoadingImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emojiLabel.layer.removeAllAnimations()
        timer?.invalidate()
    }
}

// MARK: - Private Methods
private extension SplashScreenViewController {
    func setupUI() {
        view.backgroundColor = .systemYellow
        navigationController?.isNavigationBarHidden = true
        addSubviews()
        setConstraints()
    }
    
    func addSubviews() {
        view.addSubview(emojiLabel)
        view.addSubview(loadongLabel)
    }
    
    func setConstraints() {
        setEmojiLabelConstraints()
        setLoadingLabelConstraints()
    }
    
    func setEmojiLabelConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 105)
        ])
    }
    
    func setLoadingLabelConstraints() {
        NSLayoutConstraint.activate([
            loadongLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadongLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: ConstraintSpacing.standard)
        ])
    }
    
    func animateLoadingImage() {
        UIView.animate(
            withDuration: DefaultValues.animationDuration,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseIn, .beginFromCurrentState],
            animations: {
                self.emojiLabel.transform = self.emojiLabel.transform.scaledBy(x: 0.9, y: 0.9)
            },
            completion: nil
        )
    }
    
    func initTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: DefaultValues.loadingDuration,
            target: self,
            selector: #selector(handleTimerEnd),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc
    func handleTimerEnd() {
        //route()
        onFinishLoading?()
    }
}

// MARK: Constats
private extension SplashScreenViewController {
    enum DefaultValues {
        static let animationDuration: TimeInterval = 0.5
        static let loadingDuration: TimeInterval = 3
    }
}

// MARK: Routing
private extension SplashScreenViewController {
    func route() {
        let defaults = DefaultsStorageService()
        if let loggedUser = defaults.loggedUser {
            SessionManager.shared.beginSession(username: loggedUser)
            routeToMainScreen()
        } else {
            routeToLoginScreen()
        }
    }
    
    func routeToLoginScreen() {
        let loginViewController = LoginViewController()
        navigationController?.replaceRootViewController(with: loginViewController)
    }
    
    func routeToMainScreen() {
        let market = Market(amountOfCurrencies: 5)
        let marketCurrencies = market.getCurrenciesSnapshot()
        let marketCurrenciesArray = market.getArrayOfCurrencies()
        let botViewController = BotViewController(marketCurrencies: marketCurrencies)
        let tradingViewController = TradingViewController(localCurrencies: marketCurrenciesArray)
        let settingsViewController = SettingsViewController()
        let tabBarController = UITabBarController()
        
        botViewController.tabBarItem = UITabBarItem(
            title: "Bot",
            image: UIImage(systemName: "brain")
            , tag: 0
        )
        botViewController.title = "Bot"
        
        tradingViewController.tabBarItem = UITabBarItem(
            title: "Trading",
            image: UIImage(systemName: "bitcoinsign.bank.building")
            , tag: 1
        )
        tradingViewController.title = "Trading"
        
        settingsViewController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear")
            , tag: 3
        )
        settingsViewController.title = "Settings"
        
        let botNavigationController = UINavigationController(rootViewController: botViewController)
        let tradingNavigationController = UINavigationController(rootViewController: tradingViewController)
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        tabBarController.viewControllers = [botNavigationController, tradingNavigationController, settingsNavigationController]
        navigationController?.replaceRootViewController(with: tabBarController)
    }
}

// MARK: UINavigationController Extension
extension UINavigationController {
    func replaceRootViewController(with viewController: UIViewController) {
        var controllers = viewControllers
        controllers[0] = viewController
        setViewControllers(controllers, animated: true)
    }
}
