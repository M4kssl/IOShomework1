//
//  CurrencyCell.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//



import Foundation
import UIKit

final class EmptyCell: UICollectionViewCell {
    private let noDataLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubviews()
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

// MARK: - Private Methods
private extension EmptyCell {
    func setupUI() {
        setupNoDataLabel()
    }
    
    func setupNoDataLabel() {
        noDataLabel.font = AppFonts.body
        noDataLabel.text = Texts.noDataLabelText
        noDataLabel.numberOfLines = .zero
    }
    
    func addSubviews() {
        contentView.addSubview(noDataLabel)
    }
    
    func setConstraints() {
        setNoDataLabelConstraints()
    }
    
    func setNoDataLabelConstraints() {
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            noDataLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            noDataLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            noDataLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - Identifier
extension EmptyCell {
    static let identifier = "EmptyCell"
}

// MARK: - Constants
private extension EmptyCell {
    enum Texts {
        static let noDataLabelText = "No suitable currencies"
    }
}
