//
//  OfferCell.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation
import UIKit

protocol OfferCellDelegate: AnyObject {
    func infoIconTapped()
}

final class OfferCell: UITableViewCell {
    private let offerCurrencies = UILabel()
    private let offerRate = UILabel()
    private let offerQuantity = UILabel()
    private let stackView = UIStackView()
    private let infoImage = UIImageView()
    
    private var stackViewTopConstraint: NSLayoutConstraint?
    private var stackViewLeadingConstraint: NSLayoutConstraint?
    private var stackViewTrailingConstraint: NSLayoutConstraint?
    private var stackViewBottomConstraint: NSLayoutConstraint?
    private var infoImageTopConstraint: NSLayoutConstraint?
    private var infoImageWidthConstraint: NSLayoutConstraint?
    private var infoImageHeightConstraint: NSLayoutConstraint?
    private var infoImageTrailingConstraint: NSLayoutConstraint?
    
    weak var delegate: OfferCellDelegate?
    
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
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension OfferCell {
    func nullifyConstraints() {
        stackViewTopConstraint?.isActive = false
        stackViewBottomConstraint?.isActive = false
        stackViewLeadingConstraint?.isActive = false
        stackViewTrailingConstraint?.isActive = false
        infoImageTopConstraint?.isActive = false
        infoImageWidthConstraint?.isActive = false
        infoImageHeightConstraint?.isActive = false
        infoImageTrailingConstraint?.isActive = false
        
        stackViewTopConstraint = nil
        stackViewBottomConstraint = nil
        stackViewLeadingConstraint = nil
        stackViewTrailingConstraint = nil
        infoImageTopConstraint = nil
        infoImageWidthConstraint = nil
        infoImageHeightConstraint = nil
        infoImageTrailingConstraint = nil
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
        
        infoImage.image = UIImage(systemName: "info.circle")
        infoImage.isUserInteractionEnabled = true
        infoImage.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleInfoTap)
            )
        )
    }
    
    func addSubviews() {
        contentView.addSubview(infoImage)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(offerCurrencies)
        stackView.addArrangedSubview(offerRate)
        stackView.addArrangedSubview(offerQuantity)
    }
    
    func setConstraints() {
        setStackViewConstraints()
        setInfoImageConstraints()
    }
    
    func setStackViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackViewTopConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintSpacing.standard)
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintSpacing.standard)
        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintSpacing.standard)
        stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: infoImage.leadingAnchor, constant: -ConstraintSpacing.small)
        
        stackViewTopConstraint?.isActive = true
        stackViewBottomConstraint?.isActive = true
        stackViewLeadingConstraint?.isActive = true
        stackViewTrailingConstraint?.isActive = true
    }
    
    func setInfoImageConstraints() {
        infoImage.translatesAutoresizingMaskIntoConstraints = false
        
        infoImageTopConstraint = infoImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintSpacing.small)
        infoImageWidthConstraint = infoImage.widthAnchor.constraint(lessThanOrEqualToConstant: .infoImageWidth)
        infoImageHeightConstraint = infoImage.widthAnchor.constraint(lessThanOrEqualToConstant: .infoImageHeight)
        infoImageTrailingConstraint = infoImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintSpacing.small)
        
        infoImageTopConstraint?.isActive = true
        infoImageWidthConstraint?.isActive = true
        infoImageHeightConstraint?.isActive = true
        infoImageTrailingConstraint?.isActive = true
    }
}

// MARK: - Action Handlers
private extension OfferCell {
    @objc
    func handleInfoTap() {
        delegate?.infoIconTapped()
    }
}

// MARK: - CGFloat Constants
private extension CGFloat {
    static let infoImageWidth: CGFloat = 20
    static let infoImageHeight: CGFloat = 20
}

// MARK: - Identifier
extension OfferCell {
    static let identifier = "OfferCell"
}
