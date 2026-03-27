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
            updateVeiwFromData()
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

// MARK: - Identifier
extension DealCell {
    static let identifier = "DealCell"
}

// MARK: - Private methods
private extension DealCell {
    func updateVeiwFromData() {
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
        stackView.spacing = 4
        dealLabel.font = .preferredFont(forTextStyle: .headline)
        resultLabel.font = .preferredFont(forTextStyle: .footnote)
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
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }
}

// MARK: - Deal extesion
extension Deal {
    var currencyActionText: String {
        return "\(self.currency.name) \(self.currency.value) - to \(self.action)\n"
    }
}
