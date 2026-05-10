//
//  TradingCoordinator.swift
//  homework4
//
//  Created by Максим  on 06.05.2026.
//

import Foundation
import UIKit

final class TradingCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let tradingViewController = TradingViewController(
            localCurrencies: Market(amountOfCurrencies: 5).getArrayOfCurrencies()
        )
        tradingViewController.title = "Trading"
        
        tradingViewController.onOpenWallet = { [weak self] tradingService in
            self?.openWallet(tradingService: tradingService)
        }
        
        tradingViewController.onOpenCurrencyConversion = { [weak self] tradingService in
            self?.openConversion(tradingViewController: tradingViewController, tradingService: tradingService)
        }
        
        tradingViewController.onOpenSellerDetail = { [weak self] in
            self?.openSellerDetail()
        }
        navigationController.pushViewController(tradingViewController, animated: false)
    }
    
    func openWallet(tradingService: TradingServiceProtocol) {
        let walletViewController = WalletViewController(
            walletCurrencies: tradingService.wallet.getCurrenciesOnHandSnapshot(),
            marketCurrencies: tradingService.getAllCurrenciesSnapshot()
        )
        navigationController.present(walletViewController, animated: true)
    }
    
    func openConversion(tradingViewController: TradingViewController, tradingService: TradingServiceProtocol) {
        let chosenCurrencies = [tradingService.currencyPair.firstCurrency, tradingService.currencyPair.secondCurrency]
        let conversionCoordinator = CurrencyConversionCoordinator(
            navigationController: navigationController,
            currencies: tradingService.getAllCurrenciesSnapshot(),
            chosenCurrencies: chosenCurrencies
        )
        
        conversionCoordinator.onFinish = { [weak self] allCurrencies, chosenCurrencies in
            tradingViewController.currencyConversionUpdated(
                allCurrencies: allCurrencies,
                chosenCurrencies: chosenCurrencies
            )
            self?.removeChildCoordinator(ofType: CurrencyConversionCoordinator.self)
        }
        
        conversionCoordinator.onCurrencyChosen = { chosenCurrencies in
            tradingViewController.currencyChosen(chosenCurrencies: chosenCurrencies)
        }
        
        self.addChildCoordinator(conversionCoordinator)
        conversionCoordinator.start()
    }
    
    func openSellerDetail() {
        let sellerDetailViewController = SellerDetailViewController()
        navigationController.present(sellerDetailViewController, animated: true)
    }
}
