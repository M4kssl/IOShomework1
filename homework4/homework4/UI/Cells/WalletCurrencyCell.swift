//
//  WalletCurrencyCell.swift
//  homework4
//
//  Created by Максим  on 24.04.2026.
//
import Foundation
import UIKit

final class WalletCurrencyCell: UITableViewCell {
    private let currencyLabel = UILabel()
    
    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    
    var displayedCurrency: RandomlyGeneratedCurrency? {
        didSet {
            update()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addSubviews()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nullifyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension WalletCurrencyCell {
    func update() {
        guard let displayedCurrency else { return }
        currencyLabel.text = "\(displayedCurrency.name), quantity = \(displayedCurrency.quantity.stringWithTwoDecimalPlaces), value = \(displayedCurrency.value.stringWithTwoDecimalPlaces)"
        currencyLabel.sizeToFit()
        
        setCurrencyLabelConstraints()
    }
    
    func nullifyConstraints() {
        topConstraint?.isActive = false
        bottomConstraint?.isActive = false
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        
        topConstraint = nil
        bottomConstraint = nil
        leadingConstraint = nil
        trailingConstraint = nil
    }
    
    func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        currencyLabel.font = AppFonts.body
        currencyLabel.textAlignment = .center
        currencyLabel.backgroundColor = .clear
        currencyLabel.numberOfLines = .zero
    }
    
    func addSubviews() {
        contentView.addSubview(currencyLabel)
    }
    
    func setConstraints() {
        setCurrencyLabelConstraints()
    }
    
    func setCurrencyLabelConstraints() {
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = currencyLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        bottomConstraint = currencyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        leadingConstraint = currencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        trailingConstraint = currencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        topConstraint?.isActive = true
        bottomConstraint?.isActive = true
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
    }
}

// MARK: - Identifier
extension WalletCurrencyCell {
    static let identifier = "WalletCurrencyCell"
}
