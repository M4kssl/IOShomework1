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
}

// MARK: - Private Methods
private extension CurrencyChartViewController {
    func addSubviews() {
        view.addSubview(chartCollectionView)
        view.addSubview(candlestickDetail)
        view.addSubview(recommenationLabel)
    }
    
    func setupUI() {
        view.backgroundColor = .systemYellow
        setupChartCollectionView()
        setupCandlestickDetail()
        setupRecommendationLabel()
    }
    
    func setConstraints() {
        setCandleDetailConstraints()
        setRecommendationLabelConstraints()
        setChartCollectionViewConstraints()
    }
    
    func setupChartCollectionView() {
        chartCollectionView.dataSource = self
        chartCollectionView.delegate = self
        chartCollectionView.layer.borderWidth = BorderWidth.thin
        chartCollectionView.register(ChartCell.self, forCellWithReuseIdentifier: ChartCell.identifier)
    }
    
    func setupCandlestickDetail() {
        // TODO: implement if needed
    }
    
    func setupRecommendationLabel() {
        recommenationLabel.font = AppFonts.headline
        recommenationLabel.numberOfLines = .zero
        recommenationLabel.text = DefaulValues.recommendationText
    }
    
    func setChartCollectionViewConstraints() {
        chartCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintSpacing.standard),
            chartCollectionView.topAnchor.constraint(equalTo: recommenationLabel.bottomAnchor, constant: ConstraintSpacing.standard),
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
            recommenationLabel.bottomAnchor.constraint(equalTo: chartCollectionView.topAnchor, constant: -ConstraintSpacing.standard),
            recommenationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.standard),
            recommenationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.standard),
        ])
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

// MARK: - Constants
private extension CurrencyChartViewController {
    struct DefaulValues {
        static let amountOfCandlesticks = 200
        static let recommendationText = "Choose candlestick to see recommendation"
        static let candlestickWidthToChartWidthRatio: CGFloat = 0.02
    }
}
