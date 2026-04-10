//
//  ViewController.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import UIKit

final class BotViewController: UIViewController {
    private lazy var traderBot = Bot(
        currencies: market.getAllCurrencies(),
        historyHandler: botHistoryHandler,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose
    )
    private lazy var botHistoryHandler = BotHistoryHandler()
    
    private let runButton = UIButton()
    private let currencyStackView = UIStackView()
    private let phoneImage = UIImage()
    private let superviewForTitleLabel = UIView()
    private let titleLabel = UILabel()
    private let customerSupportView = SupportInformationView()
    private let initialInfoLabel = UILabel()
    private let dealHistoryTableView = UITableView()
    private let currencyToChooseStackView = UIStackView()
    private let resetBarButton = UIBarButtonItem()
    private let chooeseRandomCurrencyBarButton = UIBarButtonItem()
    
    private var currencyLabels = [UILabel]()
    private var market = Market(amountOfCurrencies: DefaultValues.currenciesToGenerate)
    private var currenciesToChoose = [CurrencyToChooseView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
}

// MARK: - Private Methods
private extension BotViewController {
    func initViews() {
        view.backgroundColor = .systemYellow
        addSubviews()
        setupUI()
        setConstraints()
    }
    
    func addSubviews() {
        addInitialLabel()
        addRunButton()
        addDealHistoryTableView()
        addCurrencyInfoViews()
        addViewWithSubview()
        addCustomerSupportView()
        addCurrenciesToChooseStackView()
        addCurrenciesToChoose()
   }
    
    func setupUI() {
        setupInitialLabel()
        setupRunButton()
        setupDealHistoryTableView()
        setupCurrencyInfoViews()
        setupSuperviewForTitleLabel()
        setupTitleLabel()
        setupCurrenciesToChooseStackView()
        setupCurrenciesToChoose()
        setupResetBarButton()
        setupChooseRandomCurrencyBarButton()
        setupNavigationItem()
    }
    
    func setupInitialLabel() {
        initialInfoLabel.attributedText = centeredAttributedString(
            DefaultTexts.initialInfoLabel,
            fontSize: DefaultSizes.initialLabelFontSize)
        initialInfoLabel.sizeToFit()
    }
    
    func setupNavigationItem() {
        navigationItem.leftBarButtonItem = resetBarButton
        navigationItem.rightBarButtonItem = chooeseRandomCurrencyBarButton
    }
    
    func setupResetBarButton() {
        resetBarButton.title = DefaultTexts.resetBarButton
        resetBarButton.target = self
        resetBarButton.image = UIImage(systemName: "clear")
        resetBarButton.action = #selector(handleResetButtonTap)
    }
    
    func setupChooseRandomCurrencyBarButton() {
        chooeseRandomCurrencyBarButton.title = DefaultTexts.chooseRandom
        chooeseRandomCurrencyBarButton.target = self
        chooeseRandomCurrencyBarButton.image = UIImage(systemName: "dice")
        chooeseRandomCurrencyBarButton.action = #selector(handleChooseRandomCurrencyTap)
    }
    
    func setupRunButton() {
        runButton.setTitle(DefaultTexts.runButtonText, for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.titleLabel?.textColor = .white
        runButton.layer.cornerRadius = CornerRadius.standard
        runButton.addTarget(self, action: #selector(runButtonTapped), for: .touchUpInside)
    }
    
    func setupDealHistoryTableView() {
        dealHistoryTableView.register(DealCell.self, forCellReuseIdentifier: DealCell.identifier)
        dealHistoryTableView.dataSource = self
        dealHistoryTableView.alpha = .zero
        dealHistoryTableView.layer.borderWidth = BorderWidth.thin
    }
    
    func setupCurrencyInfoViews() {
        currencyStackView.spacing = StackViewSpacing.small
        currencyStackView.axis = .vertical
        currencyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        var index = 0
        for currency in market.currencies.values {
            currencyLabels[index].text = textForCurrencylabel(currency: currency)
            index += 1
        }
    }
    
    func setupSuperviewForTitleLabel() {
        superviewForTitleLabel.backgroundColor = .systemRed
    }
    
    func setupTitleLabel(){
        titleLabel.attributedText = centeredAttributedString(
            DefaultTexts.mainTitle,
            fontSize: DefaultSizes.titleLabelFontSize
        )
        titleLabel.sizeToFit()
        titleLabel.textAlignment = .center
    }
    
    func setupCurrenciesToChooseStackView() {
        currencyToChooseStackView.axis = .horizontal
        currencyToChooseStackView.spacing = StackViewSpacing.small
        currencyToChooseStackView.distribution = .fillEqually
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
    
    func addCurrenciesToChoose() {
        for _ in .zero..<DefaultValues.amountOfCurrenciesToChoose {
            let currencyView = CurrencyToChooseView()
            currenciesToChoose.append(currencyView)
            currencyToChooseStackView.addArrangedSubview(currencyView)
        }
    }
    
    func addCurrenciesToChooseStackView() {
        view.addSubview(currencyToChooseStackView)
    }
    
    func addInitialLabel() {
        view.addSubview(initialInfoLabel)
    }
    
    func addViewWithSubview() {
        superviewForTitleLabel.addSubview(titleLabel)
        view.addSubview(superviewForTitleLabel)
    }
    
    func addCurrencyInfoViews() {
        for _ in .zero..<market.currencies.count {
            let currencyLabel = UILabel()
            currencyLabels.append(currencyLabel)
            currencyStackView.addArrangedSubview(currencyLabel)
        }
        view.addSubview(currencyStackView)
    }
    
    func addCustomerSupportView() {
        customerSupportView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customerSupportView)
    }
    
    func addRunButton() {
        view.addSubview(runButton)
    }
    
    func addDealHistoryTableView() {
        view.addSubview(dealHistoryTableView)
    }
    
    // MARK: - constraints
    func setConstraints() {
        setRunButtonConstraints()
        setCurrencyStackViewConstraints()
        setTitleLabelConstraints()
        setSuperviewForTitleLabelConstraints()
        setInitialLabelConstraints()
        setCustomerSupportViewConstraints()
        setDealHistoryTableViewConstraints()
        setCurrenciesToChooseStackViewConstraints()
    }
    
    func setInitialLabelConstraints() {
        initialInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            initialInfoLabel.topAnchor.constraint(equalTo: dealHistoryTableView.topAnchor),
            initialInfoLabel.bottomAnchor.constraint(equalTo: dealHistoryTableView.bottomAnchor),
            initialInfoLabel.leadingAnchor.constraint(equalTo: dealHistoryTableView.leadingAnchor),
            initialInfoLabel.trailingAnchor.constraint(equalTo: dealHistoryTableView.trailingAnchor),
        ])
    }
    
    func setRunButtonConstraints() {
        runButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            runButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -ConstraintSpacing.standard
            ),
            runButton.heightAnchor.constraint(lessThanOrEqualToConstant: DefaultSizes.maximumRunButtonHeight),
            runButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setCurrencyStackViewConstraints() {
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
                equalTo: currencyToChooseStackView.bottomAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }
    
    func setTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: superviewForTitleLabel.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: superviewForTitleLabel.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: superviewForTitleLabel.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: superviewForTitleLabel.leadingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: superviewForTitleLabel.centerXAnchor)
        ])
    }
    
    func setSuperviewForTitleLabelConstraints() {
        superviewForTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            superviewForTitleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ConstraintSpacing.standard
            ),
            superviewForTitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: DefaultSizes.maximumTitleSuperviewHeight),
            superviewForTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func setCustomerSupportViewConstraints() {
        customerSupportView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customerSupportView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            customerSupportView.trailingAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            customerSupportView.topAnchor.constraint(
                equalTo: currencyStackView.bottomAnchor,
                constant: ConstraintSpacing.small
            ),
            customerSupportView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func setDealHistoryTableViewConstraints() {
        dealHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dealHistoryTableView.bottomAnchor.constraint(
                equalTo: runButton.topAnchor,
                constant: -ConstraintSpacing.standard
            ),
            dealHistoryTableView.topAnchor.constraint(
                lessThanOrEqualTo: customerSupportView.bottomAnchor,
                constant: ConstraintSpacing.standard
            ),
            dealHistoryTableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            dealHistoryTableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            )
        ])
    }
    
    func setCurrenciesToChooseStackViewConstraints() {
        currencyToChooseStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyToChooseStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            currencyToChooseStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            currencyToChooseStackView.topAnchor.constraint(
                equalTo: superviewForTitleLabel.bottomAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }
 
    func textForCurrencylabel(currency: RandomlyGeneratedCurrency) -> String {
        return "\(currency.name.uppercased()) - \(currency.value.stringWithTwoDecimalPlaces)"
    }
    
    func updateViewFromModel() {
        var index = 0
        for currency in market.currencies.values {
            currencyLabels[index].text = textForCurrencylabel(currency: currency)
            index += 1
        }
        dealHistoryTableView.reloadData()
        
        if traderBot.decisionsMade > .zero, dealHistoryTableView.alpha == .zero {
            crossDissolveViews(form: initialInfoLabel, to: dealHistoryTableView)
        } else if traderBot.decisionsMade == .zero, dealHistoryTableView.alpha > .zero {
            crossDissolveViews(form: dealHistoryTableView, to: initialInfoLabel)
        }
        for index in traderBot.chosenCurrencies.indices {
            currenciesToChoose[index].currencyText = traderBot.chosenCurrencies[index].stringToDisplay
        }
    }
    
    @objc
    func runButtonTapped() {
        market.updateCurrenciesValues()
        for currency in market.currencies.values {
            let action = traderBot.decideOnAction(for: currency)
            let request = traderBot.formARequestForMarket(toMake: action, for: currency)
            let response = market.processRequestAndFormAResponse(request)
            traderBot.processMarketResponse(response)
        }
        updateViewFromModel()
    }
    
    @objc
    func handleChosenCurrencyTap() {
        routeToFavoriteCurrencyConversion()
    }
    
    @objc
    func handleResetButtonTap() {
        resetBot(chosenCurrencies: traderBot.chosenCurrencies)
        updateViewFromModel()
    }
    
    @objc
    func handleChooseRandomCurrencyTap() {
        let allCurrencies = market.getAllCurrencies()
        for index in traderBot.chosenCurrencies.indices {
            if let currency = allCurrencies.randomElement() {
                traderBot.setCurrencyAsChosen(currency: currency, at: index)
            }
        }
        resetBot(chosenCurrencies: traderBot.chosenCurrencies)
        updateViewFromModel()
    }
    
    func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .headline).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font)
        let paragrapthStyle = NSMutableParagraphStyle()
        paragrapthStyle.alignment = .center
        let attributedString = NSAttributedString(string: string, attributes: [.paragraphStyle: paragrapthStyle, .font:font])
        return attributedString
    }
    
    func crossDissolveViews(form oldView: UIView, to newView: UIView) {
        UIView.animate(
            withDuration: 0.6,
            animations: {
                oldView.alpha = .zero
                newView.alpha = 1
            },
            completion: nil
        )
    }
    
    func resetBot(chosenCurrencies: [RandomlyGeneratedCurrency]) {
        traderBot = Bot(
            currencies: market.getAllCurrencies(),
            historyHandler: botHistoryHandler,
            amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose
        )
        for index in chosenCurrencies.indices {
            traderBot.setCurrencyAsChosen(currency: chosenCurrencies[index], at: index)
        }
    }
}

extension BotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return traderBot.getDealHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.identifier) as? DealCell
        cell?.displayedDeal = traderBot.getDealHistory()[indexPath.row]
        return cell ?? UITableViewCell()
    }
}

// MARK: - Constants
private extension BotViewController {
    struct DefaultValues {
        static let currenciesToGenerate = 5
        static let amountOfCurrenciesToChoose = 2
    }
    
    struct DefaultSizes {
        static let minimumTabelViewSize = CGFloat(200)
        static let initialLabelFontSize = CGFloat(50)
        static let titleLabelFontSize = CGFloat(25)
        static let maximumRunButtonHeight = CGFloat(30)
        static let maximumTitleSuperviewHeight = CGFloat(40)
    }
    
    struct DefaultTexts {
        static let runButtonText = "Run Bot"
        static let initialInfoLabel = "No data"
        static let resetBarButton = "Reset"
        static let initialCurrencyValue = "0.00"
        static let chooseRandom = "Randomize"
        static let mainTitle = "Currencies"
    }
}

// MARK: - FavoriteCurrenciesDelegate And CurrencyConversionDelegate Implementation
extension BotViewController: CurrencyConversionDelegate, FavoriteCurrenciesDelegate {
    func currencyConversionUpdated(allCurrencies: [RandomlyGeneratedCurrency], chosenCurrencies: [RandomlyGeneratedCurrency]) {
        market.updateCurrencies(with: allCurrencies)
        for index in chosenCurrencies.indices {
            traderBot.setCurrencyAsChosen(currency: chosenCurrencies[index], at: index)
        }
        updateViewFromModel()
    }
    
    func currencyChosen(chosenCurrencies: [RandomlyGeneratedCurrency]) {
        resetBot(chosenCurrencies: chosenCurrencies)
    }
    
    func showAllCurrencies(allCurrencies: [RandomlyGeneratedCurrency]) {
        market.updateCurrencies(with: allCurrencies)
        updateViewFromModel()
        routeToCurrencyConversion()
    }
}

// MARK: - Routing
private extension BotViewController {
    func routeToCurrencyConversion() {
        let conversionViewController = CurrencyConversionViewController()
        conversionViewController.chosenCurrencies = traderBot.chosenCurrencies
        conversionViewController.currenciesToDisplay = market.getAllCurrencies()
        conversionViewController.currencyConversionDelegate = self
        conversionViewController.title = "All currencies"
        navigationController?.pushViewController(conversionViewController, animated: true)
    }
    
    func routeToFavoriteCurrencyConversion() {
        let conversionViewController = FavoriteCurrenciesViewController()
        conversionViewController.chosenCurrencies = traderBot.chosenCurrencies
        conversionViewController.currenciesToDisplay = market.getAllCurrencies()
        conversionViewController.favoriteCurrenciesDelegate = self
        present(conversionViewController, animated: true)
    }
}
