//
//  CurrencyConversionCoordinator.swift
//  homework4
//
//  Created by Максим  on 06.05.2026.
//

import Foundation
import UIKit

final class CurrencyConversionCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onFinish: ((_ allCurrencies: [RandomlyGeneratedCurrency], _ chosenCurrencies: [RandomlyGeneratedCurrency]) -> Void)?
    var onCurrencyChosen: ((_ chosenCurrencies: [RandomlyGeneratedCurrency]) -> Void)?
    
    private let navigationController: UINavigationController?
    private let currencies: [RandomlyGeneratedCurrency]
    private let chosenCurrencies: [RandomlyGeneratedCurrency]
    private let isTimerNeeded: Bool
   
    init(navigationController: UINavigationController?,
         currencies: [RandomlyGeneratedCurrency],
         chosenCurrencies: [RandomlyGeneratedCurrency],
         isTimerNeeded: Bool = false) {
        self.navigationController = navigationController
        self.currencies = currencies
        self.chosenCurrencies = chosenCurrencies
        self.isTimerNeeded = isTimerNeeded
    }

    func start() {
        let conversionViewController = CurrencyConversionViewController(
            currencies: currencies,
            chosenCurrencies: chosenCurrencies,
            isTimerNeeded: isTimerNeeded
        )
        
        conversionViewController.onClosed = { [weak self] allCurrencies, chosenCurrencies in
            self?.navigationController?.popViewController(animated: true)
            self?.onFinish?(allCurrencies, chosenCurrencies)
        }
        
        conversionViewController.onCurrencyChosen = { [weak self] chosenCurrencies in
            self?.onCurrencyChosen?(chosenCurrencies)
        }
        
        if let navigationController = navigationController {
            navigationController.pushViewController(conversionViewController, animated: true)
        }
    }
}
