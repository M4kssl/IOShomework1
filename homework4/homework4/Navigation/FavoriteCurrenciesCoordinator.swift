//
//  FavoriteCurrenciesCoordinator.swift
//  homework4
//
//  Created by Максим  on 07.05.2026.
//

import Foundation
import UIKit

final class FavoriteCurrenciesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onCurrencyChosen: ((_ chosenCurrencies: [RandomlyGeneratedCurrency]) -> Void)?
    var onShowAllCurrencies: ((_ allCurrencies: [RandomlyGeneratedCurrency]) -> Void)?
    var onFinish: ((_ allCurrencies: [RandomlyGeneratedCurrency], _ chosenCurrencies: [RandomlyGeneratedCurrency]) -> Void)?

    private weak var presenter: UIViewController?
    
    private let currencies: [RandomlyGeneratedCurrency]
    private let chosen: [RandomlyGeneratedCurrency]
     
    init(presenter: UIViewController, currencies: [RandomlyGeneratedCurrency], chosen: [RandomlyGeneratedCurrency]) {
        self.presenter = presenter
        self.currencies = currencies
        self.chosen = chosen
    }
    
    func start() {
        let favoriteViewController = FavoriteCurrenciesViewController()
        favoriteViewController.chosenCurrencies = chosen
        favoriteViewController.currenciesToDisplay = currencies
        
        favoriteViewController.onClosed = { [weak self] allCurrencies, chosenCurrencies in
            self?.onFinish?(allCurrencies, chosenCurrencies)
        }
        
        favoriteViewController.onCurrencyChosen = { [weak self] chosenCurrencies in
            self?.onCurrencyChosen?(chosenCurrencies)
        }
        
        
        favoriteViewController.onShowAllCurrencies = { [weak self] allCurrencies in
            self?.presenter?.dismiss(animated: true) {
                self?.onShowAllCurrencies?(allCurrencies)
            }
        }
        
        presenter?.present(favoriteViewController, animated: true)
    }
}
