//
//  CurrencyToChooseView.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//

import Foundation
import UIKit

final class CurrencyToChooseView: UIView {
    private let currencyLabel = UILabel()
    
    var isChosen = false {
        didSet {
            updateUI()
        }
    }
    var currencyText = defaultTexts.emptyLabel {
        didSet {
            isChosen = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension CurrencyToChooseView {
    func updateUI() {
        currencyLabel.layer.backgroundColor = isChosen ? UIColor.white.cgColor : nil
        currencyLabel.text = currencyText
    }
    
    func initViews() {
        addSubviews()
        setupUI()
        setConstraints()
    }
        
    func addSubviews() {
        addSubview(currencyLabel)
    }
    
    func setupUI() {
        setupChosenCurrencyLabel()
    }
    
    func setupChosenCurrencyLabel() {
        currencyLabel.font = AppFonts.body
        currencyLabel.text = defaultTexts.emptyLabel
        currencyLabel.layer.cornerRadius = CornerRadius.standard
        currencyLabel.layer.borderWidth = BorderWidth.thin
        currencyLabel.textAlignment = .center
    }
    
    func setConstraints() {
        setCcurrencyLabelConstraints()
        setCcurrencyLabelConstraints()
    }
    
    func setCcurrencyLabelConstraints() {
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyLabel.topAnchor.constraint(equalTo: self.topAnchor),
            currencyLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            currencyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

// MARK: - Constants
private extension CurrencyToChooseView {
    struct defaultTexts {
        static let emptyLabel = "Tap to choose"
    }
}
