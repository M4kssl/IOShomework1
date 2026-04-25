//
//  LinearChartView.swift
//  homework4
//
//  Created by Максим  on 13.04.2026.
//

import Foundation
import UIKit

protocol LinearChartDelegate {
    func nodeSelected(node: ChartNode)
}

struct ChartNode {
    let point: CGPoint
    let candlestick: Candlestick
}

final class LinearChartView: UIView {
    private let chartLayer = CAShapeLayer()
    private let selectedNodeLayer = CAShapeLayer()
    private let gridLayer = CAShapeLayer()
    private let captionsLayer = CALayer()
    private let blinkingNodeLayer = CAShapeLayer()
    private let animatedLineLayer = CAShapeLayer()
    
    private var captions = [CATextLayer]()
    private var nodes = [ChartNode]()
    private var selectedNode: ChartNode?
    
    var delegate: LinearChartDelegate?
    var displayedCandlesticks: [Candlestick]?
    var highesOverallPrice: Double?
    var lowestOverallPrice: Double?
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func redraw() {
        for caption in captions {
            caption.removeFromSuperlayer()
        }
        captions.removeAll()
        
        setupLayers()
        
        drawGrid()
        drawGraph()
        drawCaptions()
        drawSelectedNode(withCenter: CGPoint.zero)
    }
}

// MARK: - UI
private extension LinearChartView {
    func setupUI() {
        backgroundColor = .white
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        addSublayers()
        setupLayers()
    }
    
    func addSublayers() {
        layer.addSublayer(gridLayer)
        layer.addSublayer(chartLayer)
        layer.addSublayer(animatedLineLayer)
        layer.addSublayer(blinkingNodeLayer)
        layer.addSublayer(selectedNodeLayer)
        layer.addSublayer(captionsLayer)
    }
    
    func setupLayers() {
        setupGridLayer()
        setupChartLayer()
        setupBlinkingNodeLayer()
        setupSelectedNodeLayer()
        setupAnimatedLineLayer()
    }
    
    func setupChartLayer() {
        chartLayer.strokeColor = ChartColor.lineColor
        chartLayer.fillColor = ChartColor.nodeColor
        chartLayer.lineWidth = calculateGraphLineWidth() ?? .zero
    }
    
    func setupAnimatedLineLayer() {
        animatedLineLayer.strokeColor = ChartColor.lineColor
        animatedLineLayer.lineWidth = calculateGraphLineWidth() ?? .zero
        addLineDrawingAnimation(toLayer: animatedLineLayer)
    }
    
    func setupBlinkingNodeLayer() {
        blinkingNodeLayer.strokeColor = ChartColor.blinkingNodeColor
        blinkingNodeLayer.fillColor = ChartColor.blinkingNodeColor
        blinkingNodeLayer.position = .zero
        blinkingNodeLayer.lineWidth = calculateGraphLineWidth() ?? .zero
        addBlinkingAnimation(toLayer: blinkingNodeLayer)
    }
    
    func setupSelectedNodeLayer() {
        selectedNodeLayer.strokeColor = ChartColor.lineColor
        selectedNodeLayer.fillColor = ChartColor.selectedNode
    }
    
    func setupGridLayer() {
        gridLayer.strokeColor = ChartColor.gridColor
        gridLayer.lineWidth = DefaultValues.gridLineWidth
    }
}

// MARK: - Private Methods
private extension LinearChartView {
    func getTappedNode(to point: CGPoint) -> ChartNode? {
        let tapableRadius = calculateTapableNodeRadius()
        guard let tapableRadius else { return nil }
        
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        var tappedNode: ChartNode?
        for node in nodes {
            let nodePoint = node.point
            let distance = hypot(nodePoint.x - point.x, nodePoint.y - point.y)
            if distance <= tapableRadius, distance < closestDistance {
                closestDistance = distance
                tappedNode = node
            }
        }
        return tappedNode
    }
    
    func calculatePriceRange() -> Double? {
        guard let highesOverallPrice, let lowestOverallPrice else { return nil }
        return highesOverallPrice - lowestOverallPrice
    }
}

// MARK: - Action Handlers
private extension LinearChartView {
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        
        guard let node = getTappedNode(to: touchPoint) else { return }
        selectedNode = node
        drawSelectedNode(withCenter: node.point)
        delegate?.nodeSelected(node: node)
    }
}

// MARK: - Drawing
private extension LinearChartView {
    func drawGraph() {
        guard let displayedCandlesticks else { return }
        
        nodes.removeAll()
        let xAxisStep = calculateNodeXAxisStep()
        let priceToHeightRatio = calculatePriceToHeightRatio()
        let radius = calculateNodeRadius()
        guard let xAxisStep, let priceToHeightRatio, let highesOverallPrice, let radius else { return }
        
        let path = UIBezierPath()
        
        var firstIndexToDraw = 0
        if displayedCandlesticks.count > DefaultValues.maximumAmountOfNodes {
            firstIndexToDraw = displayedCandlesticks.count - DefaultValues.maximumAmountOfNodes
        }
        
        for index in firstIndexToDraw..<displayedCandlesticks.endIndex {
            let xStepMultiplier = index - firstIndexToDraw
            let xPosition: CGFloat = (xAxisStep * CGFloat(xStepMultiplier)) + radius
            let nodeStartXPosition: CGFloat = (xAxisStep * CGFloat(xStepMultiplier)) + radius * 2
            let yPosition: CGFloat = (highesOverallPrice - displayedCandlesticks[index].closePrice) / priceToHeightRatio
            let center = CGPoint(x: xPosition, y: yPosition)
            let nodeStartPoint = CGPoint(x: nodeStartXPosition, y: yPosition)
            if index == displayedCandlesticks.endIndex - 1 {
                drawMovingLine(from: path.currentPoint, to: center)
                drawBlingkingNode(center: path.currentPoint)
                
                let xMovement = center.x - path.currentPoint.x
                let yMovement = center.y - path.currentPoint.y
                addStraightLineMovemetAnimation(
                    toLayer: blinkingNodeLayer,
                    xMovement: xMovement,
                    yMovement: yMovement
                )
            } else {
                // Drawing Line
                if index == firstIndexToDraw {
                    path.move(to: center)
                } else {
                    path.addLine(to: center)
                }
                
                // Drawing Node
                path.move(to: nodeStartPoint)
                path.addArc(
                    withCenter: center,
                    radius: radius,
                    startAngle: .zero,
                    endAngle: .pi * 2,
                    clockwise: true
                )
                path.move(to: center)
            }
            
            let newNode = ChartNode(point: center, candlestick: displayedCandlesticks[index])
            nodes.append(newNode)
        }
        chartLayer.path = path.cgPath
    }
    
    func drawSelectedNode(withCenter center: CGPoint) {
        let radius = calculateNodeRadius()
        let path = UIBezierPath()
        
        if let radius, center != CGPoint.zero {
            let nodePoint = CGPoint(x: center.x + radius, y: center.y)
            
            path.move(to: nodePoint)
            path.addArc(
                withCenter: center,
                radius: radius,
                startAngle: .zero,
                endAngle: .pi * 2,
                clockwise: true
            )
            selectedNodeLayer.path = path.cgPath
        } else {
            selectedNodeLayer.path = nil
        }
    }
    
    func drawGrid() {
        let xStep = calculateGridXAxisStep()
        let yStep = calculateGridYAxisStep()
        
        let path = UIBezierPath()
        
        for counter in .zero...DefaultValues.amountOfHorizontalGridLines {
            let yPosition = CGFloat(counter) * yStep
            let xStart: CGFloat = .zero
            let xEnd = bounds.width
            
            let startPoint = CGPoint(x: xStart, y: yPosition)
            let endPoint = CGPoint(x: xEnd, y: yPosition)
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        for counter in .zero...DefaultValues.amountOfVerticalGridLines {
            let xPosition = CGFloat(counter) * xStep
            let yStart: CGFloat = .zero
            let yEnd = bounds.height
            
            let startPoint = CGPoint(x: xPosition, y: yStart)
            let endPoint = CGPoint(x: xPosition, y: yEnd)
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        gridLayer.path = path.cgPath
    }
    
    func drawCaptions() {
        drawYAxisCaptions()
        drawXAxisCaptions()
    }
    
    func drawYAxisCaptions() {
        let priceRange = calculatePriceRange()
        guard let priceRange, let highesOverallPrice else { return }
       
        let priceStep = priceRange / Double(DefaultValues.amountOfHorizontalGridLines)
        let yStep = calculateGridYAxisStep()
        
        for counter in 1..<DefaultValues.amountOfHorizontalGridLines {
            let displayedPrice = highesOverallPrice - priceStep * Double(counter)
            let yPosition = yStep * CGFloat(counter)
            let point = CGPoint(x: .zero, y: yPosition)
            let caption = createCaption(
                forPoint: point,
                displayingText: displayedPrice.stringWithTwoDecimalPlaces
            )
            captionsLayer.addSublayer(caption)
            captions.append(caption)
        }
    }
    
    func drawXAxisCaptions() {
        let xStep = calculateGridXAxisStep()
        for counter in 1..<DefaultValues.amountOfVerticalGridLines {
            let xPosition = xStep * CGFloat(counter)
            let yPosition = bounds.height
            let point = CGPoint(x: xPosition, y: yPosition)
            let text = "April \(counter)"
            let caption = createCaption(
                forPoint: point,
                displayingText: String(text)
            )
            captionsLayer.addSublayer(caption)
            captions.append(caption)
        }
    }
    
    func createCaption(forPoint point: CGPoint, displayingText text: String) -> CATextLayer {
        let caption = CATextLayer()
        caption.string = text
        caption.fontSize = calculateCaptionFontSize()
        caption.foregroundColor = ChartColor.gridColor
        caption.alignmentMode = .center
        
        let captionSize = caption.preferredFrameSize()
        
        caption.frame = CGRect(
            x: point.x,
            y: point.y - captionSize.height,
            width: captionSize.width,
            height: captionSize.height
        )
        return caption
    }
    
    func drawBlingkingNode(center: CGPoint) {
        if let radius = calculateNodeRadius() {
            let path = UIBezierPath()
            let nodeStartPoint = CGPoint(x: center.x + radius, y: center.y)
            
            path.move(to: nodeStartPoint)
            path.addArc(
                withCenter: center,
                radius: radius,
                startAngle: .zero,
                endAngle: .pi * 2,
                clockwise: true
            )
            path.move(to: center)
            
            blinkingNodeLayer.path = path.cgPath
        }
    }
    
    func drawMovingLine(from startPoint: CGPoint, to endPoint: CGPoint) {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        animatedLineLayer.path = path.cgPath
    }
}

// MARK: - Animations
private extension LinearChartView {
    func addBlinkingAnimation(toLayer layer: CAShapeLayer) {
        let blinkAnimation = CABasicAnimation(keyPath: "opacity")
        blinkAnimation.fromValue = 1
        blinkAnimation.toValue = 0.5
        blinkAnimation.duration = 1
        blinkAnimation.autoreverses = true
        blinkAnimation.repeatCount = .infinity
        
        layer.add(blinkAnimation, forKey: "blinkAnimation")
    }
    
    func addLineDrawingAnimation(toLayer animatedLayer: CAShapeLayer) {
        let lineAnimation = CABasicAnimation(keyPath: "strokeEnd")
        lineAnimation.fromValue = 0
        lineAnimation.toValue = 1
        lineAnimation.duration = DefaultValues.drawingLineAnimationTime
        lineAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineAnimation.fillMode = .forwards
        lineAnimation.isRemovedOnCompletion = false
        
        animatedLayer.add(lineAnimation, forKey: "drawingLine")
    }
    
    func addStraightLineMovemetAnimation(toLayer animatedLayer: CAShapeLayer, xMovement: CGFloat, yMovement: CGFloat) {
        
        let pointTomoveTo = CGPoint(
            x: animatedLayer.position.x + xMovement,
            y: animatedLayer.position.y + yMovement
        )
        let movementAnimation = CABasicAnimation(keyPath: "position")
        movementAnimation.fromValue = animatedLayer.position
        movementAnimation.toValue = pointTomoveTo
        movementAnimation.duration = DefaultValues.drawingLineAnimationTime
        movementAnimation.fillMode = .forwards
        movementAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
       
        animatedLayer.position = pointTomoveTo
        
        animatedLayer.add(movementAnimation, forKey: "movement")
    }
}

// MARK: - Constants
private extension LinearChartView {
    enum ChartColor {
        static let lineColor = UIColor.systemBlue.cgColor
        static let nodeColor = UIColor.systemBlue.cgColor
        static let blinkingNodeColor = UIColor.systemRed.cgColor
        static let gridColor = UIColor.systemGray.cgColor
        static let selectedNode = UIColor.green.cgColor
    }
    
    enum Multipliers {
        static let graphLineWidth: CGFloat = 0.2
        static let nodeRadius: CGFloat = 0.5
        static let blinkingDodeRadius: CGFloat = 0.75
        static let tapableNodeRadius: CGFloat = 1
        static let captonHeight: CGFloat = 0.2
    }
    
    enum DefaultValues {
        static let gridLineWidth: CGFloat = 0.5
        static let amountOfHorizontalGridLines = 8
        static let amountOfVerticalGridLines = 6
        static let maximumAmountOfNodes = 30
        static let drawingLineAnimationTime: TimeInterval = 2
    }
}

// MARK: - Sizes
private extension LinearChartView {
    func calculatePriceToHeightRatio() -> CGFloat? {
        if let highesOverallPrice, let lowestOverallPrice{
            let height = bounds.height
            let totalRange = highesOverallPrice - lowestOverallPrice
            return totalRange / height
        }
        return nil
    }
    
    func calculateNodeXAxisStep() -> CGFloat? {
        if let displayedCandlesticks {
            var quantityToDisplay = DefaultValues.maximumAmountOfNodes
            if displayedCandlesticks.count < DefaultValues.maximumAmountOfNodes {
                quantityToDisplay = displayedCandlesticks.count
            }
            return bounds.width / CGFloat(quantityToDisplay)
        }
        return nil
    }
    
    func calculateWidthToQuantityhRatio() -> CGFloat? {
        if let displayedCandlesticks {
            var quantityToDisplay = DefaultValues.maximumAmountOfNodes
            if displayedCandlesticks.count < DefaultValues.maximumAmountOfNodes {
                quantityToDisplay = displayedCandlesticks.count
            }
            return bounds.width / CGFloat(quantityToDisplay)
        }
        return nil
    }
    
    func calculateGridXAxisStep() -> CGFloat {
        return bounds.width / CGFloat(DefaultValues.amountOfVerticalGridLines)
    }
    
    func calculateGridYAxisStep() -> CGFloat {
        return bounds.height / CGFloat(DefaultValues.amountOfHorizontalGridLines)
    }
    
    func calculateNodeRadius() -> CGFloat? {
        let widthToQuantityhRatio = calculateWidthToQuantityhRatio()
        if let widthToQuantityhRatio {
            return widthToQuantityhRatio * Multipliers.nodeRadius
        }
        return nil
    }
    
    func calculateGraphLineWidth() -> CGFloat? {
        let widthToQuantityhRatio = calculateWidthToQuantityhRatio()
        if let widthToQuantityhRatio {
            return widthToQuantityhRatio * Multipliers.graphLineWidth
        }
        return nil
    }
    
    func calculateCaptionFontSize() -> CGFloat {
        return bounds.height / CGFloat(DefaultValues.amountOfHorizontalGridLines) * Multipliers.captonHeight
    }
    
    func calculateGridLineWidth() -> CGFloat? {
        let widthToQuantityhRatio = calculateWidthToQuantityhRatio()
        if let widthToQuantityhRatio {
            return widthToQuantityhRatio * DefaultValues.gridLineWidth
        }
        return nil
    }
    
    func calculateTapableNodeRadius() -> CGFloat? {
        let widthToQuantityhRatio = calculateWidthToQuantityhRatio()
        if let widthToQuantityhRatio {
            return widthToQuantityhRatio * Multipliers.tapableNodeRadius
        }
        return nil
    }
    
    func calculateBlinkingNodeRadius() -> CGFloat? {
        let widthToQuantityhRatio = calculateWidthToQuantityhRatio()
        if let widthToQuantityhRatio {
            return widthToQuantityhRatio * Multipliers.blinkingDodeRadius
        }
        return nil
    }
}
