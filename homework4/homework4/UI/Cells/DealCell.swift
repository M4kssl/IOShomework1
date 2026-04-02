//
//  DealCell.swift
//  homework4
//
//  Created by Максим  on 25.03.2026.
//

import Foundation
import UIKit

final class DealCell: UITableViewCell {
    private let stackView = UIStackView()
    private let dealLabel = UILabel()
    private let resultLabel = UILabel()
    
    var displayedDeal: Deal? {
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension DealCell {
    func update() {
        guard let displayedDeal else { return }
        dealLabel.text = displayedDeal.currencyActionText
        dealLabel.sizeToFit()
        switch displayedDeal.action {
        case .purchase:
            contentView.backgroundColor = .green
        case .sell:
            contentView.backgroundColor = .red
        case .ignore:
            contentView.backgroundColor = .yellow
        }
        resultLabel.text = displayedDeal.result
        resultLabel.sizeToFit()
    }
    
    func setupUI() {
        contentView.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = stackViewSpacing.extraSmall
        dealLabel.font = AppFonts.headline
        resultLabel.font = AppFonts.footnote
        resultLabel.numberOfLines = .zero
    }
    
    func addSubviews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(dealLabel)
        stackView.addArrangedSubview(resultLabel)
    }
    
    func setConstraints() {
        setStackViewConstraints()
    }
    
    func setStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: constraintSpacing.extraSmall),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -constraintSpacing.extraSmall),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: constraintSpacing.extraSmall),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -constraintSpacing.extraSmall)
        ])
    }
}

// MARK: - Deal extesion
extension Deal {
    var currencyActionText: String {
        return "\(self.currency.name) \(self.currency.value.stringWithTwoDecimalPlaces) - to \(self.action)\n"
    }
}

// MARK: - Identifier
extension DealCell {
    static let identifier = "DealCell"
}
