//
//  CurrencyChartViewController.swift
//  homework4
//
//  Created by Максим  on 08.04.2026.
//

import Foundation
import UIKit

final class CurrencyChartViewController: UIViewController {
    private let chartDataGenerator = ChartDataGenerator()
    private let recommenationLabel = UILabel()
    private let candlestickDetail = CandlestickDetail()
    private let avalibleRecommentadions = ["Recommended to buy", "Recommended to sell", "Recommended to ignore"]
    private let linearChart = LinearChartView()
    private let chartSelectionStackView = UIStackView()
    private let candlestickChartButton = UIButton()
    private let linearChartButton = UIButton()
    
    private var chartLayot: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(
            top: ConstraintSpacing.small,
            left: ConstraintSpacing.small,
            bottom: ConstraintSpacing.small,
            right: ConstraintSpacing.small)
        return layout
    }()
    
    private lazy var chartCollectionView = UICollectionView(frame: .zero, collectionViewLayout: chartLayot)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartDataGenerator.generateCandles(amountOfCandles: DefaulValues.amountOfCandlesticks)
        addSubviews()
        setupUI()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chartCollectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Private Methods
private extension CurrencyChartViewController {
    func addSubviews() {
        view.addSubview(chartCollectionView)
        view.addSubview(candlestickDetail)
        view.addSubview(recommenationLabel)
        view.addSubview(linearChart)
        
        view.addSubview(chartSelectionStackView)
        chartSelectionStackView.addArrangedSubview(candlestickChartButton)
        chartSelectionStackView.addArrangedSubview(linearChartButton)
    }
    
    func setupUI() {
        view.backgroundColor = .systemYellow
        setupChartCollectionView()
        setupRecommendationLabel()
        setupLinearChart()
        setupChartSelectionStackView()
        setupCandlestickChartButton()
        setupLinearChartButton()
    }
    
    func setConstraints() {
        setCandleDetailConstraints()
        setRecommendationLabelConstraints()
        setChartCollectionViewConstraints()
        setLinearChartConstraints()
        setChartSelectionStackViewConstraints()
    }
    
    func setupChartCollectionView() {
        chartCollectionView.dataSource = self
        chartCollectionView.delegate = self
        chartCollectionView.layer.borderWidth = BorderWidth.thin
        chartCollectionView.register(ChartCell.self, forCellWithReuseIdentifier: ChartCell.identifier)
    }
    
    func setupChartSelectionStackView() {
        chartSelectionStackView.spacing = StackViewSpacing.extraSmall
        chartSelectionStackView.distribution = .fillEqually
        chartSelectionStackView.axis = .horizontal
    }
    
    func setupCandlestickChartButton() {
        candlestickChartButton.setTitle(DefaulValues.candlestickChartButtonText, for: .normal)
        candlestickChartButton.layer.borderWidth = BorderWidth.thin
        candlestickChartButton.layer.cornerRadius = CornerRadius.small
        candlestickChartButton.backgroundColor = .white
        candlestickChartButton.setTitleColor(.systemBlue, for: .selected)
        candlestickChartButton.setTitleColor(.black, for: .normal)
        candlestickChartButton.isSelected = true
        candlestickChartButton.addTarget(self, action: #selector(handleChartButtonTap), for: .touchUpInside)
    }
    
    func setupLinearChartButton() {
        linearChartButton.setTitle(DefaulValues.candlestickChartButtonText, for: .normal)
        linearChartButton.layer.borderWidth = BorderWidth.thin
        linearChartButton.layer.cornerRadius = CornerRadius.small
        linearChartButton.backgroundColor = .white
        linearChartButton.setTitleColor(.systemBlue, for: .selected)
        linearChartButton.setTitleColor(.black, for: .normal)
        linearChartButton.addTarget(self, action: #selector(handleChartButtonTap), for: .touchUpInside)
    }
    
    func setupRecommendationLabel() {
        recommenationLabel.font = AppFonts.headline
        recommenationLabel.numberOfLines = .zero
        recommenationLabel.text = DefaulValues.recommendationText
    }
    
    func setupLinearChart() {
        linearChart.displayedCandlesticks = chartDataGenerator.candlesticks
        let minMaxPrices = chartDataGenerator.getTotalMinMaxPrices()
        linearChart.lowestOverallPrice = minMaxPrices.min
        linearChart.highesOverallPrice = minMaxPrices.max
        linearChart.delegate = self
        linearChart.alpha = .zero
    }
    
    func setChartCollectionViewConstraints() {
        chartCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintSpacing.standard),
            chartCollectionView.topAnchor.constraint(equalTo: chartSelectionStackView.bottomAnchor, constant: ConstraintSpacing.standard),
            chartCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.standard),
            chartCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.standard)
        ])
        chartCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setCandleDetailConstraints() {
        candlestickDetail.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            candlestickDetail.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ConstraintSpacing.standard),
            candlestickDetail.bottomAnchor.constraint(equalTo: recommenationLabel.topAnchor, constant: -ConstraintSpacing.standard),
            candlestickDetail.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.standard),
            candlestickDetail.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.standard),
        ])
    }
    
    func setRecommendationLabelConstraints() {
        recommenationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recommenationLabel.topAnchor.constraint(equalTo: candlestickDetail.bottomAnchor, constant: ConstraintSpacing.standard),
            recommenationLabel.bottomAnchor.constraint(equalTo: chartSelectionStackView.topAnchor, constant: -ConstraintSpacing.standard),
            recommenationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.standard),
            recommenationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.standard),
        ])
    }
    
    func setLinearChartConstraints() {
        linearChart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            linearChart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintSpacing.standard),
            linearChart.topAnchor.constraint(equalTo: chartSelectionStackView.bottomAnchor, constant: ConstraintSpacing.standard),
            linearChart.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.standard),
            linearChart.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.standard)
        ])
    }
    
    func setChartSelectionStackViewConstraints() {
        chartSelectionStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartSelectionStackView.topAnchor.constraint(equalTo: recommenationLabel.bottomAnchor, constant: ConstraintSpacing.standard),
            chartSelectionStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.standard),
            chartSelectionStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.standard)
        ])
    }
    
    func crossDissolveViews(form oldView: UIView, to newView: UIView) {
        UIView.animate(
            withDuration: 0.4,
            animations: {
                oldView.alpha = .zero
                newView.alpha = 1
            },
            completion: nil
        )
    }
    
    func updateChartButtonsState(lastTappedButton: UIButton) {
        candlestickChartButton.isSelected = lastTappedButton == candlestickChartButton
        linearChartButton.isSelected = lastTappedButton == linearChartButton
    }
}

// MARK: - UICollectionViewDataSource Implementation
extension CurrencyChartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chartDataGenerator.candlesticks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCell.identifier, for: indexPath) as? ChartCell
        cell?.displayedCandlestick = chartDataGenerator.candlesticks[indexPath.row]
        
        let minMaxPrices = chartDataGenerator.getTotalMinMaxPrices()
        cell?.lowestOverallPrice = minMaxPrices.min
        cell?.highesOverallPrice = minMaxPrices.max
        cell?.delegate = self
        cell?.configureCandlestick()
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - Action Handlers
private extension CurrencyChartViewController {
    @objc
    func handleChartButtonTap(_ sender: UIButton) {
        if sender == candlestickChartButton {
            crossDissolveViews(form: linearChart, to: chartCollectionView)
        } else {
            crossDissolveViews(form: chartCollectionView, to: linearChart)
            linearChart.redraw()
        }
        updateChartButtonsState(lastTappedButton: sender)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Implementation
extension CurrencyChartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let width = height * DefaulValues.candlestickWidthToChartWidthRatio
        return CGSize(width: width, height: height)
    }
}

// MARK: - ChartCellDelegate Implementation
extension CurrencyChartViewController: ChartCellDelegate {
    func showDetail(for candlestick: Candlestick) {
        candlestickDetail.displayedCandlestick = candlestick
    }
    
    func giveRecommendation(for candlestick: Candlestick) {
        recommenationLabel.text = avalibleRecommentadions.randomElement()
    }
}

// MARK: - LinearChartDelegate Implementation
extension CurrencyChartViewController: LinearChartDelegate {
    func nodeSelected(node: ChartNode) {
        candlestickDetail.displayedCandlestick = node.candlestick
    }
}

// MARK: - Constants
private extension CurrencyChartViewController {
    struct DefaulValues {
        static let amountOfCandlesticks = 40
        static let recommendationText = "Choose candlestick to see recommendation"
        static let candlestickWidthToChartWidthRatio: CGFloat = 0.04
        static let candlestickChartButtonText = "Candlestick chart"
        static let linearChartButtonText = "Linear chart"
    }
}
