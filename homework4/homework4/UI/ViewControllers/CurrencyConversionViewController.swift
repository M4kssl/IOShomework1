//
//  CurrencyCnversionVeiewController.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//

import Foundation
import UIKit

final class CurrencyConversionViewController: UIViewController {
    private let currencyDataGenerator = CurrencyDataProvider(
        aomuntOfCurrencies: DefaultValues.amountOfCurrencuesToGenerate,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose
    )
    private let showAllButton = UIButton()
    private let showFiatButton = UIButton()
    private let showCryptoButton = UIButton()
    private let filterButtonsStackView = UIStackView()
    private let currencyStackView = UIStackView()
    private let timerLabel = UILabel()
    private let amountToConvertTextField = UITextField()
    private let conversionResultLabel = UILabel()
    private let conversionStackView = UIStackView()
    private let favoriteFilterSwitch = FavoriteFilterSwitch()
    
    private var timer: Timer?
    private var timerLabelText: String {
        return "Time before update: \(timerTimeLeft.stringWithTwoDecimalPlaces)"
    }
    private var timerTimeLeft: Double = .zero
    private var conversionResultText: String {
        return "\(conversionResult.stringWithTwoDecimalPlaces) \(currencyDataGenerator.chosenCurrencies[DefaultValues.convertToCurrencyIndex].name)"
    }
    private var selectedCurrecnyToChooseIndex: Int? {
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
       
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrencyDataGenerator()
        initViews()
        initTimer()
        currencyDataGenerator.generateNewValues()
        updateViewFromModel()
    }
}

// MARK: - Private Methods
private extension CurrencyConversionViewController {
    func updateViewFromModel() {
        let currencyToReselectIndex = selectedCurrecnyToChooseIndex
        for index in currencyDataGenerator.chosenCurrencies.indices {
            currenciesToChoose[index].currencyText = currencyDataGenerator.chosenCurrencies[index].stringToDisplay
        }
        currencyCollectionView.reloadData()
        updateConversionResult()
        if let currencyToReselectIndex {
            currenciesToChoose[currencyToReselectIndex].isChosen = true
        }
    }
    
    func updateFilterButtonsState(lastTappedButton: UIButton) {
        showAllButton.isSelected = lastTappedButton == showAllButton
        showFiatButton.isSelected = lastTappedButton == showFiatButton
        showCryptoButton.isSelected = lastTappedButton == showCryptoButton
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
        
        currencyCollectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.identifier)
        currencyCollectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.identifier)
        view.addSubview(currencyCollectionView)
        
        view.addSubview(favoriteFilterSwitch)
        
        filterButtonsStackView.addArrangedSubview(showAllButton)
        filterButtonsStackView.addArrangedSubview(showFiatButton)
        filterButtonsStackView.addArrangedSubview(showCryptoButton)
        view.addSubview(filterButtonsStackView)
        view.addSubview(timerLabel)
        
        conversionStackView.addArrangedSubview(amountToConvertTextField)
        conversionStackView.addArrangedSubview(conversionResultLabel)
        view.addSubview(conversionStackView)
    }
    
    func setupUI() {
        view.backgroundColor = .systemYellow
        setupCurrencyStackView()
        setupCurrenciesToChoose()
        setupCurrencyCollectionView()
        setupFilterButtonsStackView()
        setupShowAllButton()
        setupShowFiatButton()
        setupShowCryptoButton()
        setupTimerLabel()
        setupConversionStackView()
        setupAmountToConvertTextField()
        setupConversionResultLabel()
        setupFavoriteFilterSwitch()
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
        currencyDataGenerator.delegate = self
    }
    
    func setupFilterButtonsStackView() {
        filterButtonsStackView.axis = .horizontal
        filterButtonsStackView.spacing = StackViewSpacing.extraSmall
        filterButtonsStackView.distribution = .fillEqually
    }
    
    func setupShowAllButton() {
        showAllButton.setTitle(Texts.showAllButtonText, for: .normal)
        showAllButton.layer.borderWidth = BorderWidth.thin
        showAllButton.layer.cornerRadius = CornerRadius.small
        showAllButton.backgroundColor = .white
        showAllButton.setTitleColor(.systemBlue, for: .selected)
        showAllButton.setTitleColor(.black, for: .normal)
        showAllButton.isSelected = true
        showAllButton.addTarget(self, action: #selector(handleFilterButtonTap), for: .touchUpInside)
    }
    
    func setupShowFiatButton() {
        showFiatButton.setTitle(Texts.showFiatButtonText, for: .normal)
        showFiatButton.layer.borderWidth = BorderWidth.thin
        showFiatButton.layer.cornerRadius = CornerRadius.small
        showFiatButton.backgroundColor = .white
        showFiatButton.setTitleColor(.systemBlue, for: .selected)
        showFiatButton.setTitleColor(.black, for: .normal)
        showFiatButton.addTarget(self, action: #selector(handleFilterButtonTap), for: .touchUpInside)
    }
    
    func setupShowCryptoButton() {
        showCryptoButton.setTitle(Texts.showCryptoButtonText, for: .normal)
        showCryptoButton.layer.borderWidth = BorderWidth.thin
        showCryptoButton.layer.cornerRadius = CornerRadius.small
        showCryptoButton.backgroundColor = .white
        showCryptoButton.setTitleColor(.systemBlue, for: .selected)
        showCryptoButton.setTitleColor(.black, for: .normal)
        showCryptoButton.addTarget(self, action: #selector(handleFilterButtonTap), for: .touchUpInside)
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
    
    func setupFavoriteFilterSwitch() {
        favoriteFilterSwitch.delegate = self
    }
    
    func setConstraints() {
        setCurrencyStakViewConstraints()
        setCurrencyCollectionViewConstraints()
        setFilterButtonsStackViewConstraints()
        setTimerLabelConstraints()
        setConversionStackViewConstraints()
        setFavoriteFilterSwitchConstraints()
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
    
    func setFilterButtonsStackViewConstraints() {
        filterButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterButtonsStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            filterButtonsStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            filterButtonsStackView.topAnchor.constraint(
                equalTo: favoriteFilterSwitch.bottomAnchor,
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
                equalTo: filterButtonsStackView.bottomAnchor,
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
                equalTo: currencyStackView.bottomAnchor,
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
    
    func setFavoriteFilterSwitchConstraints() {
        favoriteFilterSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteFilterSwitch.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            favoriteFilterSwitch.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            favoriteFilterSwitch.topAnchor.constraint(
                equalTo: conversionStackView.bottomAnchor,
                constant: ConstraintSpacing.standard
            )
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
private extension CurrencyConversionViewController {
    @objc
    func handleTimerTick() {
        timerTimeLeft -= DefaultValues.timerTimeInterval
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
    func handleFilterButtonTap(_ sender: UIButton) {
        if sender == showFiatButton {
            currencyDataGenerator.filterCurrenciesByType(CurrencyType.fiat)
        } else if sender == showCryptoButton {
            currencyDataGenerator.filterCurrenciesByType(CurrencyType.crypto)
        } else {
            currencyDataGenerator.clearFilterByType()
        }
        updateFilterButtonsState(lastTappedButton: sender)
        updateViewFromModel()
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
}

extension CurrencyConversionViewController: CurrencyDelegatePrtocol {
    func currencyChosen(_ currency: RandomlyGeneratedCurrency) {
        if let selectedCurrecnyToChooseIndex, !currency.isChosen {
            deselectAllCurrenciesToChoose()
            currencyDataGenerator.chooseCurrency(currency: currency, chosenCurrenciesIndex: selectedCurrecnyToChooseIndex)
            updateViewFromModel()
        }
    }
    
    func favoriteMarkChanged() {
        updateViewFromModel()
    }
}

extension CurrencyConversionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let decimalCharacters = CharacterSet(charactersIn: String.allDecimalCharacters)
        let characterSet = CharacterSet(charactersIn: string)
        return decimalCharacters.isSuperset(of: characterSet)
    }
}

extension CurrencyConversionViewController: FavoriteFilterSwitchDelegate {
    func switchFilter(isFilterOn: Bool) {
        currencyDataGenerator.switchFilterByFavorite(isFilterOn: isFilterOn)
        updateViewFromModel()
    }
}

// MARK: - Constants
private extension CurrencyConversionViewController {
    struct DefaultValues {
        static let amountOfCurrencuesToGenerate = Int.random(in: 100...200)
        static let amountOfCurrenciesToChoose = 2
        static let layotItemSize = CGSize(width: 150, height: 60)
        static let convertFromCurrencyIndex = 0
        static let convertToCurrencyIndex = 1
        static let timerDuration: Double = 5
        // Timer ticks every one hundredth of a second
        static let timerTimeInterval = 0.01
    }
    
    struct Texts {
        static let showAllButtonText = "Show all"
        static let showFiatButtonText = "Show fiat"
        static let showCryptoButtonText = "Show crypto"
    }
}

private extension String {
    static var allDecimalCharacters: String {
        return "0123456789."
    }
}
