//
//  WalletViewController.swift
//  homework4
//
//  Created by Максим  on 24.04.2026.
//

import Foundation
import UIKit

final class WalletViewController: UIViewController {
    private let walletCurrencies: [UUID : RandomlyGeneratedCurrency]
    private let currentMarketCurrencies: [RandomlyGeneratedCurrency]
    private let walletBalanceTableView = UITableView()
    
    private var updatedWalletCurrencies = [RandomlyGeneratedCurrency]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addSubviews()
        setConstraints()
        synchronizeWalletAndMarketPrices()
    }
    
    init(walletCurrencies: [UUID : RandomlyGeneratedCurrency], marketCurrencies: [RandomlyGeneratedCurrency]) {
        self.walletCurrencies = walletCurrencies
        self.currentMarketCurrencies = marketCurrencies
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -  Private Methods
private extension WalletViewController {
    func setupUI() {
        view.backgroundColor = UIColor.systemYellow
        setupWalletBalanceTableView()
    }
    
    func addSubviews() {
        view.addSubview(walletBalanceTableView)
    }
    
    func setConstraints() {
        setWalletBalanceTableViewConstraints()
    }
    
    func setupWalletBalanceTableView() {
        walletBalanceTableView.register(WalletCurrencyCell.self, forCellReuseIdentifier: WalletCurrencyCell.identifier)
        walletBalanceTableView.dataSource = self
        walletBalanceTableView.backgroundColor = .clear
        walletBalanceTableView.layer.borderWidth = BorderWidth.thin
    }
    
    func setWalletBalanceTableViewConstraints() {
        walletBalanceTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            walletBalanceTableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -ConstraintSpacing.standard
            ),
            walletBalanceTableView.topAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ConstraintSpacing.standard
            ),
            walletBalanceTableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            walletBalanceTableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            )
        ])
    }
    
    func synchronizeWalletAndMarketPrices() {
        updatedWalletCurrencies.removeAll()
        for currency in self.currentMarketCurrencies {
            if let walletCurrency = walletCurrencies[currency.id] {
                let updatedCurrency = RandomlyGeneratedCurrency.changeValueForCurrency(
                    currency: walletCurrency,
                    newValue: currency.value
                )
                updatedWalletCurrencies.append(updatedCurrency)
            }
        }
    }
}

// MARK: - UITableViewDataSource Implementation
extension WalletViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updatedWalletCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletCurrencyCell.identifier) as? WalletCurrencyCell
        cell?.displayedCurrency = updatedWalletCurrencies[indexPath.row]
        return cell ?? UITableViewCell()
    }
}
