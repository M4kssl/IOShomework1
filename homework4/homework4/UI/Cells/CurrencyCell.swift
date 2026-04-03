//
//  CurrencyCell.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//



import Foundation
import UIKit

final class CurrencyCell: UICollectionViewCell {
    private let currencyDataLabel = UILabel()
    
    var displayedCurrency: RandomlyGeneratedCurrency? {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubviews()
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension CurrencyCell {
    func update() {
        guard displayedCurrency != nil else { return }
        currencyDataLabel.text = displayedCurrency?.stringToDisplay
        currencyDataLabel.textColor = displayedCurrency?.isChosen ?? false ? .gray : .black
        currencyDataLabel.sizeToFit()
    }
    
    func setupUI() {
        contentView.layer.borderWidth = 1
        currencyDataLabel.font = AppFonts.footnote
    }
    
    func addSubviews() {
        contentView.addSubview(currencyDataLabel)
    }
    
    func setConstraints() {
       setCurrencyDataLabelConstraints()
    }
    
    func setCurrencyDataLabelConstraints() {
        currencyDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyDataLabel.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
            ),
            currencyDataLabel.bottomAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.bottomAnchor
            ),
            currencyDataLabel.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: constraintSpacing.extraSmall
            ),
            currencyDataLabel.trailingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -constraintSpacing.extraSmall
            )
        ])
    }
}

// MARK: - Identifier
extension CurrencyCell {
    static let identifier = "CurrencyCell"
}
