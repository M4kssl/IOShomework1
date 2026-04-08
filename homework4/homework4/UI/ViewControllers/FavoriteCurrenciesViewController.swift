//
//  FavoriteCurrenciesViewController.swift
//  homework4
//
//  Created by Максим  on 06.02.2026.
//

import Foundation
import UIKit

protocol FavoriteCurrenciesDelegate: AnyObject {
    func currencyConversionUpdated(allCurrencies: [RandomlyGeneratedCurrency], chosenCurrencies: [RandomlyGeneratedCurrency])
    func currencyChosen(chosenCurrencies: [RandomlyGeneratedCurrency])
    func showAllCurrencies(allCurrencies: [RandomlyGeneratedCurrency])
}

final class FavoriteCurrenciesViewController: UIViewController {
    private let currencyStackView = UIStackView()
    private let timerLabel = UILabel()
    private let amountToConvertTextField = UITextField()
    private let conversionResultLabel = UILabel()
    private let conversionStackView = UIStackView()
    private let showAllButton = UIButton()
    
    private var currencyDataGenerator = CurrencyDataProvider(
        aomuntOfCurrencies: DefaultValues.amountOfCurrencuesToGenerate,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose
    )
    private var timer: Timer?
    private var timerLabelText: String {
        return "Time before update: \(timerTimeLeft.stringWithTwoDecimalPlaces)"
    }
    private var timerTimeLeft: Double = DefaultValues.timerDuration
    private var conversionResultText: String {
        return "\(conversionResult.stringWithTwoDecimalPlaces) \(currencyDataGenerator.chosenCurrencies[DefaultValues.convertToCurrencyIndex].name)"
    }
    private var selectedCurrencyToChooseIndex: Int? {
        return currenciesToChoose.firstIndex(where: { $0.isChosen })
    }
    private var conversionResult: Double = .zero {
        didSet {
            updateConversionResultLabel()
        }
    }
    private var currenciesToChoose = [CurrencyToChooseView]()
    private var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = DefaultValues.layotItemSize
        layout.sectionInset = UIEdgeInsets(
            top: ConstraintSpacing.small,
            left: ConstraintSpacing.small,
            bottom: ConstraintSpacing.small,
            right: ConstraintSpacing.small)
        return layout
    }()
    private lazy var currencyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    var currenciesToDisplay: [RandomlyGeneratedCurrency]?
    var chosenCurrencies: [RandomlyGeneratedCurrency]?
    weak var favoriteCurrenciesDelegate: FavoriteCurrenciesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrencyDataGenerator()
        initViews()
        initTimer()
        currencyDataGenerator.generateNewValues()
        updateViewFromModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
}

// MARK: - Private Methods
private extension FavoriteCurrenciesViewController {
    func updateViewFromModel() {
        let currencyToReselectIndex = selectedCurrencyToChooseIndex
        for index in currencyDataGenerator.chosenCurrencies.indices {
            currenciesToChoose[index].currencyText = currencyDataGenerator.chosenCurrencies[index].stringToDisplay
        }
        currencyCollectionView.reloadData()
        updateConversionResult()
        if let currencyToReselectIndex {
            currenciesToChoose[currencyToReselectIndex].isChosen = true
        }
        favoriteCurrenciesDelegate?.currencyConversionUpdated(
            allCurrencies: currencyDataGenerator.allCurrencies,
            chosenCurrencies: currencyDataGenerator.chosenCurrencies
        )
    }
    
    func updateConversionResult() {
        let conversionRate = currencyDataGenerator.convertCurrency(
            atChosenCurrencyIndex: DefaultValues.convertFromCurrencyIndex,
            toChosenCurrencyIndex: DefaultValues.convertToCurrencyIndex
        )
        conversionResult = conversionRate * (Double(amountToConvertTextField.text ?? "0") ?? .zero)
    }
    
    func updateConversionResultLabel() {
        conversionResultLabel.text = conversionResultText
    }
    
    func updateTimerLabel() {
        timerLabel.text = timerLabelText
    }
    
    func initViews() {
        addSubviews()
        setupUI()
        setConstraints()
    }
    
    func addSubviews() {
        for _ in .zero..<DefaultValues.amountOfCurrenciesToChoose {
            let currencyView = CurrencyToChooseView()
            currenciesToChoose.append(currencyView)
            currencyStackView.addArrangedSubview(currencyView)
        }
        view.addSubview(currencyStackView)
        view.addSubview(showAllButton)
        view.addSubview(timerLabel)

        currencyCollectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.identifier)
        currencyCollectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.identifier)
        view.addSubview(currencyCollectionView)
        
        conversionStackView.addArrangedSubview(amountToConvertTextField)
        conversionStackView.addArrangedSubview(conversionResultLabel)
        view.addSubview(conversionStackView)
    }
    
    func setupUI() {
        view.backgroundColor = .systemYellow
        setupCurrencyStackView()
        setupCurrenciesToChoose()
        setupCurrencyCollectionView()
        setupTimerLabel()
        setupConversionStackView()
        setupAmountToConvertTextField()
        setupConversionResultLabel()
        setupAllCurrenciesButton()
    }
    
    func setupCurrenciesToChoose() {
        for index in currenciesToChoose.indices {
            currenciesToChoose[index].isUserInteractionEnabled = true
            currenciesToChoose[index].addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(handleChosenCurrencyTap)
                )
            )
        }
    }
    
    func setupAllCurrenciesButton() {
        showAllButton.setTitle(Texts.showAllButtonText, for: .normal)
        showAllButton.layer.borderWidth = BorderWidth.thin
        showAllButton.layer.cornerRadius = CornerRadius.small
        showAllButton.backgroundColor = .white
        showAllButton.setTitleColor(.systemBlue, for: .selected)
        showAllButton.setTitleColor(.black, for: .normal)
        showAllButton.isSelected = true
        showAllButton.addTarget(self, action: #selector(handleShowAllButtonTap), for: .touchUpInside)

    }
    
    func setupCurrencyCollectionView() {
        currencyCollectionView.dataSource = currencyDataGenerator
        currencyCollectionView.delegate = currencyDataGenerator
        currencyCollectionView.backgroundColor = .white
    }
    
    func setupCurrencyStackView() {
        currencyStackView.axis = .horizontal
        currencyStackView.spacing = StackViewSpacing.small
        currencyStackView.distribution = .fillEqually
    }
    
    func setupCurrencyDataGenerator() {
        if let chosenCurrencies, let currencies = currenciesToDisplay {
            currencyDataGenerator = CurrencyDataProvider(
                currencies: currencies,
                chosenCurrencies: chosenCurrencies
            )
        }
        currencyDataGenerator.delegate = self
        currencyDataGenerator.switchFilterByFavorite(isFilterOn: true)
    }
    
    func setupTimerLabel() {
        timerLabel.font = AppFonts.headline
        timerLabel.text = timerLabelText
    }
    
    func setupConversionStackView() {
        conversionStackView.axis = .horizontal
        conversionStackView.spacing = StackViewSpacing.standard
        conversionStackView.distribution = .fillEqually
    }
    
    func setupAmountToConvertTextField() {
        amountToConvertTextField.font = AppFonts.body
        amountToConvertTextField.layer.borderWidth = BorderWidth.thin
        amountToConvertTextField.keyboardType = .decimalPad
        amountToConvertTextField.delegate = self
        amountToConvertTextField.backgroundColor = .white
        amountToConvertTextField.addTarget(self, action: #selector(handleAmountToConvertChange), for: .editingChanged)
    }
    
    func setupConversionResultLabel() {
        conversionResultLabel.font = AppFonts.body
    }
    
    func setConstraints() {
        setCurrencyStakViewConstraints()
        setCurrencyCollectionViewConstraints()
        setTimerLabelConstraints()
        setConversionStackViewConstraints()
        setShowAllButtonConstraints()
    }
    
    func setCurrencyStakViewConstraints() {
        currencyStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            currencyStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            currencyStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }

    func setCurrencyCollectionViewConstraints() {
        currencyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -ConstraintSpacing.standard
            ),
            currencyCollectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            currencyCollectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            currencyCollectionView.topAnchor.constraint(
                equalTo: conversionStackView.bottomAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }
    
    func setTimerLabelConstraints() {
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            timerLabel.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            timerLabel.topAnchor.constraint(
                equalTo: showAllButton.bottomAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }
    
    func setConversionStackViewConstraints() {
        conversionStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            conversionStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            conversionStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            conversionStackView.topAnchor.constraint(
                equalTo: timerLabel.bottomAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }
    
    func setShowAllButtonConstraints() {
        showAllButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showAllButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.extraLarge
            ),
            showAllButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.extraLarge
            ),
            showAllButton.topAnchor.constraint(
                equalTo: currencyStackView.bottomAnchor,
                constant: ConstraintSpacing.standard
            ),
            showAllButton.heightAnchor.constraint(lessThanOrEqualToConstant: DefaultValues.maximumButtonHeight)
        ])
    }
    
    func initTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: DefaultValues.timerTimeInterval,
            target: self,
            selector: #selector(handleTimerTick),
            userInfo: nil,
            repeats: true
        )
    }
    
    func deselectAllCurrenciesToChoose() {
        for index in currenciesToChoose.indices {
            currenciesToChoose[index].isChosen = false
        }
    }
}

//MARK: - Action Handlers
private extension FavoriteCurrenciesViewController {
    @objc
    func handleTimerTick() {
        timerTimeLeft -= 0.01
        updateTimerLabel()
        if timerTimeLeft <= .zero {
            currencyDataGenerator.generateNewValues()
            updateViewFromModel()
            timerTimeLeft = DefaultValues.timerDuration
        }
    }
    
    @objc
    func handleChosenCurrencyTap(_ gesture: UITapGestureRecognizer) {
        if let currencyToChoose = gesture.view as? CurrencyToChooseView {
            if !currencyToChoose.isChosen {
                deselectAllCurrenciesToChoose()
            }
            currencyToChoose.isChosen = !currencyToChoose.isChosen
        }
    }
    
    @objc
    func handleAmountToConvertChange(_ sender: UITextField) {
        updateConversionResult()
        let conversionRate = currencyDataGenerator.convertCurrency(
            atChosenCurrencyIndex: DefaultValues.convertFromCurrencyIndex,
            toChosenCurrencyIndex: DefaultValues.convertToCurrencyIndex
        )
        conversionResult = conversionRate * (Double(sender.text ?? "0") ?? .zero)
    }
    
    @objc
    func handleShowAllButtonTap() {
        favoriteCurrenciesDelegate?.showAllCurrencies(allCurrencies: currencyDataGenerator.allCurrencies)
        dismiss(animated: true)
    }
}

// MARK: - CurrencyDelegateProtocol Implementation
extension FavoriteCurrenciesViewController: CurrencyDelegatePrtocol {
    func currencyChosen(_ currency: RandomlyGeneratedCurrency) {
        if let selectedCurrencyToChooseIndex, !currency.isChosen {
            deselectAllCurrenciesToChoose()
            currencyDataGenerator.chooseCurrency(currency: currency, chosenCurrenciesIndex: selectedCurrencyToChooseIndex)
            favoriteCurrenciesDelegate?.currencyChosen(chosenCurrencies: currencyDataGenerator.chosenCurrencies)
            updateViewFromModel()
        }
    }
    
    func favoriteMarkChanged() {
        updateViewFromModel()
    }
}

// MARK: - UITextFieldDelegate Implemenatanion
extension FavoriteCurrenciesViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let decimalCharacters = CharacterSet(charactersIn: String.allDecimalCharacters)
        let characterSet = CharacterSet(charactersIn: string)
        return decimalCharacters.isSuperset(of: characterSet)
    }
}

// MARK: - Constants
private extension FavoriteCurrenciesViewController {
    struct DefaultValues {
        static let amountOfCurrencuesToGenerate = Int.random(in: 100...200)
        static let amountOfCurrenciesToChoose = 2
        static let layotItemSize = CGSize(width: 150, height: 60)
        static let convertFromCurrencyIndex = 0
        static let convertToCurrencyIndex = 1
        static let timerDuration: Double = 5
        static let maximumButtonHeight = CGFloat(30)
        // Timer ticks every one hundredth of a second
        static let timerTimeInterval = 0.01
    }
    
    struct Texts {
        static let showAllButtonText = "Show all"
    }
}

private extension String {
    static var allDecimalCharacters: String {
        return "0123456789."
    }
}
