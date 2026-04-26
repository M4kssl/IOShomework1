//
//  OfferCell.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation
import UIKit

final class OfferCell: UITableViewCell {
    private let offerCurrencies = UILabel()
    private let offerRate = UILabel()
    private let offerQuantity = UILabel()
    private let stackView = UIStackView()

    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    var displayedOffer: Offer? {
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
    
    func update() {
        guard let displayedOffer else { return }
        offerCurrencies.text = "\(displayedOffer.currencyPair.firstCurrency.name) - \(displayedOffer.currencyPair.secondCurrency.name)"
        offerRate.text = "exchangeRate: \(displayedOffer.exchangeRate)"
        offerQuantity.text = "quantity: \(displayedOffer.currencyPair.secondCurrency.quantity)"
        
        setStackViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension OfferCell {
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
        contentView.backgroundColor = .white
        
        offerCurrencies.font = AppFonts.body
        offerCurrencies.numberOfLines = .zero
        
        offerRate.font = AppFonts.body
        offerRate.numberOfLines = .zero
        
        offerQuantity.font = AppFonts.body
        offerQuantity.numberOfLines = .zero
        
        stackView.axis = .vertical
        stackView.spacing = StackViewSpacing.extraSmall

    }
    
    func addSubviews() {
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(offerCurrencies)
        stackView.addArrangedSubview(offerRate)
        stackView.addArrangedSubview(offerQuantity)
    }
    
    func setConstraints() {
        setStackViewConstraints()
    }
    
    func setStackViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintSpacing.standard)
        bottomConstraint = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintSpacing.standard)
        leadingConstraint = stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintSpacing.standard)
        trailingConstraint = stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintSpacing.standard)
        
        topConstraint?.isActive = true
        bottomConstraint?.isActive = true
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
    }
}

// MARK: - Identifier
extension OfferCell {
    static let identifier = "OfferCell"
}
