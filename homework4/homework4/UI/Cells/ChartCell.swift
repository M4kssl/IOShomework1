//
//  ChartCell.swift
//  homework4
//
//  Created by Максим  on 08.04.2026.
//

import Foundation
import UIKit

protocol ChartCellDelegate {
    func giveRecommendation(for candlestick: Candlestick)
    func showDetail(for candlestick: Candlestick)
}

final class ChartCell: UICollectionViewCell {
    private let bodyView = UIView()
    private let shadowView = UIView()
    
    private var bodyHeightConstraint: NSLayoutConstraint?
    private var bodyLeadingConstraint: NSLayoutConstraint?
    private var bodyTrailingConstraint: NSLayoutConstraint?
    private var bodyTopConstraint: NSLayoutConstraint?
    
    private var shadowHeightConstraint: NSLayoutConstraint?
    private var shadowWidthConstraint: NSLayoutConstraint?
    private var shadowTopConstraint: NSLayoutConstraint?
    private var shadowCenerXConstraint: NSLayoutConstraint?
    
    var highesOverallPrice: Double?
    var lowestOverallPrice: Double?
    var displayedCandlestick: Candlestick?
    var delegate: ChartCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubviews()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCandlestick() {
        configureColors()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nullifyConstraints()
        contentView.subviews.forEach( { $0.removeFromSuperview() })
        addSubviews()
        setupUI()
    }
}

// MARK: - Private Methods
private extension ChartCell {
    func configureColors() {
        if let displayedCandlestick {
            let fillColor = displayedCandlestick.openClosePriceRange < 0 ? Colors.priceDownColor : Colors.priceUpColor
            bodyView.backgroundColor = fillColor
            shadowView.backgroundColor = fillColor
        }
    }
    
    func addSubviews() {
        contentView.addSubview(shadowView)
        contentView.addSubview(bodyView)
    }
    
    func setupUI() {
        setupBodyView()
        setupShadowView()
    }
    
    func setupBodyView() {
        bodyView.layer.borderWidth = BorderWidth.standard
        bodyView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleCandlestickTap),
                
            )
        )
        bodyView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleCandlestickLongPress),
                
            )
        )
    }
    
    func setupShadowView() {
        shadowView.layer.borderWidth = BorderWidth.standard
        shadowView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleCandlestickTap),
                
            )
        )
        shadowView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleCandlestickLongPress),
                
            )
        )
    }
    
    func setConstraints() {
        setBodyConstraints()
        setShadowConstraints()
    }
    
    func setBodyConstraints() {
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        if let displayedCandlestick {
            let priceRange = displayedCandlestick.openClosePriceRange
            var topAnchorOffset: CGFloat?
            var height: CGFloat?
            
            if priceRange < 0 {
                topAnchorOffset = calculateTopOffset(forPrice: displayedCandlestick.openPrice)
                height = calculateHeigt(
                    minimumPrice: displayedCandlestick.closePrice,
                    maximumPrice: displayedCandlestick.openPrice
                )
            } else {
                topAnchorOffset = calculateTopOffset(forPrice: displayedCandlestick.closePrice)
                height = calculateHeigt(
                    minimumPrice: displayedCandlestick.openPrice,
                    maximumPrice: displayedCandlestick.closePrice
                )
            }
            
            if let height, let topAnchorOffset {
                bodyHeightConstraint = bodyView.heightAnchor.constraint(equalToConstant: height)
                bodyTopConstraint = bodyView.topAnchor.constraint(
                    equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                    constant: topAnchorOffset)
                bodyLeadingConstraint = bodyView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor)
                bodyTrailingConstraint = bodyView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
                
                bodyHeightConstraint?.isActive = true
                bodyTopConstraint?.isActive = true
                bodyLeadingConstraint?.isActive = true
                bodyTrailingConstraint?.isActive = true
            }
        }
    }
    
    func setShadowConstraints() {
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        if let displayedCandlestick {
            let topAnchorOffset = calculateTopOffset(forPrice: displayedCandlestick.maximumPrice)
            let width = calculateShadowWidth()
            let height = calculateHeigt(
                minimumPrice: displayedCandlestick.minimumPrice,
                maximumPrice: displayedCandlestick.maximumPrice
            )
            
            if let height, let topAnchorOffset {
                shadowHeightConstraint = shadowView.heightAnchor.constraint(equalToConstant: height)
                shadowTopConstraint = shadowView.topAnchor.constraint(
                    equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                    constant: topAnchorOffset)
                shadowWidthConstraint = shadowView.widthAnchor.constraint(equalToConstant: width)
                shadowCenerXConstraint = shadowView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
                
                shadowHeightConstraint?.isActive = true
                shadowTopConstraint?.isActive = true
                shadowWidthConstraint?.isActive = true
                shadowCenerXConstraint?.isActive = true
            }
        }
    }
    
    func nullifyConstraints() {
        
        bodyHeightConstraint?.isActive = false
        bodyLeadingConstraint?.isActive = false
        bodyTrailingConstraint?.isActive = false
        bodyTopConstraint?.isActive = false
        
        shadowHeightConstraint?.isActive = false
        shadowWidthConstraint?.isActive = false
        shadowTopConstraint?.isActive = false
        shadowCenerXConstraint?.isActive = false
        
        bodyHeightConstraint = nil
        bodyLeadingConstraint = nil
        bodyTrailingConstraint = nil
        bodyTopConstraint = nil
        
        shadowHeightConstraint = nil
        shadowWidthConstraint = nil
        shadowTopConstraint = nil
        shadowCenerXConstraint = nil
    }
    
    func calculateShadowWidth() -> CGFloat {
        return bounds.width * 0.1
    }
    
    func calculatePriceToHeightRatio() -> CGFloat? {
        let height = bounds.height
        if let highesOverallPrice, let lowestOverallPrice, height > 0 {
            let totalRange = highesOverallPrice - lowestOverallPrice
            let height = bounds.height
            return totalRange / height
        } else {
            return nil
        }
    }
    
    func calculateTopOffset(forPrice price: Double) -> CGFloat? {
        let ratio = calculatePriceToHeightRatio()
        if let ratio, let highesOverallPrice {
            let offset = CGFloat(highesOverallPrice - price) / ratio
            return offset
        }
        return nil
    }
    
    func calculateHeigt(minimumPrice: Double, maximumPrice: Double) -> CGFloat? {
        let ratio = calculatePriceToHeightRatio()
        if let ratio {
            let height = CGFloat(maximumPrice - minimumPrice) / ratio
            return height
        }
        return nil
    }
}

// MARK: - Action Handlers
private extension ChartCell {
    @objc
    func handleCandlestickLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .ended:
            if let displayedCandlestick {
                delegate?.giveRecommendation(for: displayedCandlestick)
            }
        default:
            break
        }
    }
    
    @objc
    func handleCandlestickTap() {
        if let displayedCandlestick {
            delegate?.showDetail(for: displayedCandlestick)
        }
    }
}

// MARK: - Identifier
extension ChartCell {
    static let identifier = "ChartCell"
}

// MARK: - Constants
private extension ChartCell {
    struct Colors {
        static let priceUpColor = UIColor.systemGreen
        static let priceDownColor = UIColor.systemRed
    }
}
