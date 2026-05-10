//
//  BotCoordinator.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation
import UIKit

final class BotCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let market = Market(amountOfCurrencies: 5)
        let marketCurrencies = market.getCurrenciesSnapshot()
        let botViewController = BotViewController(marketCurrencies: marketCurrencies)
        botViewController.title = "Bot"
        
        openChartSetup(botViewController: botViewController)
        openWalletSetup(botViewController: botViewController)
        openConversionSetup(botViewController: botViewController)
        openFavoriteSetup(botViewController: botViewController)
        navigationController.pushViewController(botViewController, animated: false)
    }
}

private extension BotCoordinator {
    func openWalletSetup(botViewController: BotViewController) {
        botViewController.onOpenWallet = { [weak self] market, wallet in
            let walletViewController = WalletViewController(
                walletCurrencies: wallet.getCurrenciesOnHandSnapshot(),
                marketCurrencies: market.getArrayOfCurrencies()
            )
            self?.navigationController.present(walletViewController, animated: true)
        }
    }
    
    func openConversionSetup(botViewController: BotViewController) {
        botViewController.onOpenCurrencyConversion = { [weak self] currencies, chosenCurrencies in
            let conversionCoordinator = CurrencyConversionCoordinator(
                navigationController: self?.navigationController,
                currencies: currencies,
                chosenCurrencies: chosenCurrencies,
                isTimerNeeded: true
            )
            
            conversionCoordinator.onFinish = { [weak self] allCurrencies, chosenCurrencies in
                botViewController.currencyConversionUpdated(
                    allCurrencies: allCurrencies,
                    chosenCurrencies: chosenCurrencies
                )
                self?.removeChildCoordinator(ofType: CurrencyConversionCoordinator.self)
            }
            
            conversionCoordinator.onCurrencyChosen = { chosenCurrencies in
                botViewController.currencyChosen(chosenCurrencies: chosenCurrencies)
            }
            self?.addChildCoordinator(conversionCoordinator)
            conversionCoordinator.start()
        }
    }
    
    func openChartSetup(botViewController: BotViewController) {
        botViewController.onOpenChart = { [weak self] in
            let chartViewController = CurrencyChartViewController()
            self?.navigationController.present(chartViewController, animated: true)
        }
    }
    
    func openFavoriteSetup(botViewController: BotViewController) {
        botViewController.onOpenFavoriteCurrencies = { [weak self] currencies, chosenCurrencies in
            guard let self else { return }
            let favoriteCoordinator = FavoriteCurrenciesCoordinator(
                presenter: self.navigationController,
                currencies: currencies,
                chosen: chosenCurrencies
            )
            favoriteCoordinator.onCurrencyChosen = { chosenCurrencies in
                botViewController.currencyChosen(chosenCurrencies: chosenCurrencies)
            }
            
            favoriteCoordinator.onShowAllCurrencies = { allCurrencies in
                botViewController.showAllCurrencies(allCurrencies: allCurrencies)
            }
            self.addChildCoordinator(favoriteCoordinator)
            favoriteCoordinator.start()
        }
        
    }
}
