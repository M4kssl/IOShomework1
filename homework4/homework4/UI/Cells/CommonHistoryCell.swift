//
//  CommonHistoryCell.swift
//  homework4
//
//  Created by Максим  on 24.04.2026.
//

import Foundation
import UIKit

final class CommonHistoryCell: UITableViewCell {
    private let resultLabel = UILabel()
    
    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    
    var displayedResult: DayResult? {
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
private extension CommonHistoryCell {
    func update() {
        guard let displayedResult else { return }
        resultLabel.text = "\(displayedResult.botName), day = \(displayedResult.day), income = \(displayedResult.income.stringWithTwoDecimalPlaces)"
        resultLabel.sizeToFit()
        
        setResultLabelConstraints()
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
        contentView.backgroundColor = .white
        resultLabel.font = AppFonts.footnote
        resultLabel.numberOfLines = .zero
    }
    
    func addSubviews() {
        contentView.addSubview(resultLabel)
    }
    
    func setConstraints() {
        setResultLabelConstraints()
    }
    
    func setResultLabelConstraints() {
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = resultLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        bottomConstraint = resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        leadingConstraint = resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        trailingConstraint = resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        topConstraint?.isActive = true
        bottomConstraint?.isActive = true
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
    }
}

// MARK: - Identifier
extension CommonHistoryCell {
    static let identifier = "CommonHistoryCell"
}
