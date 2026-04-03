//
//  CurrencyCell.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//



import Foundation
import UIKit

protocol CurrencyCellDelegate: AnyObject {
    func favoiteMarkChanged(for currency: RandomlyGeneratedCurrency)
}

final class CurrencyCell: UICollectionViewCell {
    private let currencyDataLabel = UILabel()
    private let starImageView = UIImageView()
    private let stackView = UIStackView()
    weak var delegate: CurrencyCellDelegate?
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        starImageView.image = nil
        delegate = nil
        contentView.layer.borderColor = UIColor.black.cgColor
        currencyDataLabel.textColor = .black
    }
}

// MARK: - Private Methods
private extension CurrencyCell {
    func update() {
        guard displayedCurrency != nil else { return }
        currencyDataLabel.text = displayedCurrency?.stringToDisplay
        currencyDataLabel.sizeToFit()
        starImageView.image = getStarImage()
        if displayedCurrency?.isChosen ?? false {
            contentView.layer.borderColor = UIColor.gray.cgColor
            currencyDataLabel.textColor = .gray
        }
    }
    
    func setupUI() {
        contentView.layer.borderWidth = BorderWidth.thin
        setupCurrencyDataLabel()
        setupStarImageView()
    }
    
    func setupCurrencyDataLabel() {
        currencyDataLabel.font = AppFonts.footnote
    }
    
    func setupStarImageView() {
        starImageView.contentMode = .scaleAspectFit
        starImageView.isUserInteractionEnabled = true
        starImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleStarTap),
                
            )
        )
    }
    
    func addSubviews() {
        contentView.addSubview(currencyDataLabel)
        contentView.addSubview(starImageView)
    }
    
    func setConstraints() {
        setCurrencyDataLabelConstraints()
        setFavoritedStarConstraints()
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
                constant: ConstraintSpacing.extraSmall
            ),
            currencyDataLabel.trailingAnchor.constraint(
                equalTo: starImageView.leadingAnchor,
                constant: -ConstraintSpacing.extraSmall
            )
        ])
    }
    
    func setFavoritedStarConstraints() {
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -ConstraintSpacing.extraSmall
            ),
            starImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: ConstraintSpacing.extraSmall
            ),
            starImageView.widthAnchor.constraint(lessThanOrEqualToConstant: StarSize.width),
            starImageView.heightAnchor.constraint(lessThanOrEqualToConstant: StarSize.height)
        ])
    }
    
    @objc
    func handleStarTap(_ gesture: UITapGestureRecognizer) {
        if let displayedCurrency {
            delegate?.favoiteMarkChanged(for: displayedCurrency)
        }
    }
}

// MARK: Drawing Star
private extension CurrencyCell {
    func drawStar(in rect: CGRect, context: CGContext) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = min(rect.width, rect.height) * 0.4
        let path = UIBezierPath()
        let angles = [-90, -54, -18, 18, 54, 90, 126, 162, 198, 234]
        
        for (index, angleDeg) in angles.enumerated() {
            let angleRad = CGFloat(angleDeg) * .pi / 180
            let distance = index % 2 == 0 ? radius : radius * 0.4
            
            let point = CGPoint(
                x: center.x + distance * cos(angleRad),
                y: center.y + distance * sin(angleRad)
            )
            
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        UIColor(red: 0.8, green: 0.6, blue: .zero, alpha: 1.0).setStroke()
        path.lineWidth = 3
        path.stroke()
       
        if displayedCurrency?.isFavorited ?? false {
            UIColor(red: 1.0, green: 0.84, blue: .zero, alpha: 1.0).setFill()
            path.fill()
        }
    }
    
    func getStarImage() -> UIImage {
        let imageRenderer = UIGraphicsImageRenderer(size: CGSize(
            width: StarSize.renderWidth,
            height: StarSize.renderHeight
        ))
        let starImage = imageRenderer.image { context in
            let starRect = CGRect(x: .zero, y: .zero, width: StarSize.renderWidth, height: StarSize.renderHeight)
            drawStar(in: starRect, context: context.cgContext)
        }
        return starImage
    }
}

// MARK: - Constants
private extension CurrencyCell {
    struct StarSize {
        static let width = CGFloat(30)
        static let height = CGFloat(30)
        static let renderWidth = CGFloat(120)
        static let renderHeight = CGFloat(120)
    }
}

// MARK: - Identifier
extension CurrencyCell {
    static let identifier = "CurrencyCell"
}
