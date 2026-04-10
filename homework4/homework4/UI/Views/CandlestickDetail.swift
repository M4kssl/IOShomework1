//
//  CandlestickDetail.swift
//  homework4
//
//  Created by Максим  on 10.04.2026.
//

import Foundation
import UIKit

final class CandlestickDetail: UIView {
    private let detalStackView = UIStackView()
    private let openPriceLabel = UILabel()
    private let closePriceLabel = UILabel()
    private let minimumPriceLabel = UILabel()
    private let maximumPriceLabel = UILabel()
    
    var displayedCandlestick: Candlestick?
    {
        didSet {
            updateUI()
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

private extension CandlestickDetail {
    func updateUI() {
        minimumPriceLabel.text = minimumPriceText
        maximumPriceLabel.text = maximumPriceText
        openPriceLabel.text = openPriceText
        closePriceLabel.text = closePriceText
    }
    
    func addSubviews() {
        addSubview(detalStackView)
        detalStackView.addArrangedSubview(openPriceLabel)
        detalStackView.addArrangedSubview(closePriceLabel)
        detalStackView.addArrangedSubview(minimumPriceLabel)
        detalStackView.addArrangedSubview(maximumPriceLabel)
    }
    
    func setupUI() {
        setupDetalStackView()
        setupOpenPriceLabel()
        setupClosePriceLabel()
        setupMinimumPriceLabel()
        setupMaximumPriceLabel()
    }
    
    func setupDetalStackView() {
        detalStackView.axis = .vertical
        detalStackView.spacing = StackViewSpacing.small
    }
    
    func setupOpenPriceLabel() {
        openPriceLabel.font = AppFonts.body
        openPriceLabel.text = openPriceText
    }
    func setupClosePriceLabel() {
        closePriceLabel.font = AppFonts.body
        closePriceLabel.text = closePriceText
    }
    func setupMinimumPriceLabel() {
        minimumPriceLabel.font = AppFonts.body
        minimumPriceLabel.text = minimumPriceText
    }
    func setupMaximumPriceLabel() {
        maximumPriceLabel.font = AppFonts.body
        maximumPriceLabel.text = maximumPriceText
    }
    
    func setConstraints() {
        setDetailStackViewConstraints()
    }
    
    func setDetailStackViewConstraints() {
        detalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            detalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            detalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            detalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

// MARK: - Computed Properties
private extension CandlestickDetail {
    var maximumPriceText: String {
        return "Maximum price - \(displayedCandlestick?.maximumPrice.stringWithTwoDecimalPlaces ?? "0.00")"
    }
    var minimumPriceText: String {
        return "Minimum price - \(displayedCandlestick?.minimumPrice.stringWithTwoDecimalPlaces ?? "0.00")"
    }
    var openPriceText: String {
        return "Open price - \(displayedCandlestick?.openPrice.stringWithTwoDecimalPlaces ?? "0.00")"
    }
    var closePriceText: String {
        return "Close price - \(displayedCandlestick?.closePrice.stringWithTwoDecimalPlaces ?? "0.00")"
    }
    
}
