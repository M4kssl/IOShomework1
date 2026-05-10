//
//  ViewController.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import UIKit

final class BotViewController: UIViewController {
    private lazy var traderBot = Bot(
        currencies: market.getArrayOfCurrencies(),
        historyHandler: botHistoryHandler,
        wallet: wallet,
        walletHandler: walletHandler,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose,
        namePostfix: "MAIN"
    )
    
    private lazy var botDave = Bot(
        currencies: market.getArrayOfCurrencies(),
        historyHandler: botHistoryHandler,
        wallet: wallet,
        walletHandler: walletHandler,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose,
        namePostfix: "Dave"
    )
    
    private lazy var botJerry = Bot(
        currencies: market.getArrayOfCurrencies(),
        historyHandler: botHistoryHandler,
        wallet: wallet,
        walletHandler: walletHandler,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose,
        namePostfix: "Jerry"
    )
    
    private lazy var botAndy = Bot(
        currencies: market.getArrayOfCurrencies(),
        historyHandler: botHistoryHandler,
        wallet: wallet,
        walletHandler: walletHandler,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose,
        namePostfix: "Andy"
    )
    private lazy var botDaniel = Bot(
        currencies: market.getArrayOfCurrencies(),
        historyHandler: botHistoryHandler,
        wallet: wallet,
        walletHandler: walletHandler,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose,
        namePostfix: "Daniel"
    )
    
    private lazy var botSam = Bot(
        currencies: market.getArrayOfCurrencies(),
        historyHandler: botHistoryHandler,
        wallet: wallet,
        walletHandler: walletHandler,
        amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose,
        namePostfix: "Sam"
    )
    
    private lazy var botHistoryHandler = BotHistoryHandler()
    private lazy var walletHandler = WalletHandler()
    
    private let botsQueue = DispatchQueue(label: "botsQueue", attributes: .concurrent)
    private let runButton = UIButton()
    private let openChartButton = UIButton()
    private let phoneImage = UIImage()
    private let superviewForTitleLabel = UIView()
    private let titleLabel = UILabel()
    private let customerSupportView = SupportInformationView()
    private let initialInfoLabel = UILabel()
    private let dealHistoryTableView = UITableView()
    private let commonDealHistoryTableView = UITableView()
    private let currencyToChooseStackView = UIStackView()
    private let resetBarButton = UIBarButtonItem()
    private let chooeseRandomCurrencyBarButton = UIBarButtonItem()
    private let openWalletBarButton = UIBarButtonItem()
    private let market: MarketProtocol
    private let wallet: WalletProtocol
    
    private var commonHistory = [DayResult]()
    private var currenciesToChoose = [CurrencyToChooseView]()
    
    var onOpenCurrencyConversion: (([RandomlyGeneratedCurrency], [RandomlyGeneratedCurrency]) -> Void)?
    var onOpenWallet: ((MarketProtocol, WalletProtocol) -> Void)?
    var onOpenChart: (() -> Void)?
    var onOpenFavoriteCurrencies: (([RandomlyGeneratedCurrency], [RandomlyGeneratedCurrency]) -> Void)?
    
    init(marketCurrencies: [UUID : RandomlyGeneratedCurrency]) {
        self.market = Market(currencies: marketCurrencies)
        wallet = Wallet(currencies: market.getArrayOfCurrencies())
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        updateViewFromModel()
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
        addCommonDealHistoryTableView()
        addViewWithSubview()
        addCustomerSupportView()
        addCurrenciesToChooseStackView()
        addCurrenciesToChoose()
        addOpenChartButton()
   }
    
    func setupUI() {
        let swipeRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(handleRootViewSvipe)
        )
        swipeRecognizer.direction = .up
        view.addGestureRecognizer(swipeRecognizer)
        view.isUserInteractionEnabled = true
        setupInitialLabel()
        setupRunButton()
        setupDealHistoryTableView()
        setupCommonDealHistoryTableView()
        setupSuperviewForTitleLabel()
        setupTitleLabel()
        setupCurrenciesToChooseStackView()
        setupCurrenciesToChoose()
        setupResetBarButton()
        setupChooseRandomCurrencyBarButton()
        setupOpenWalletBarButton()
        setupNavigationItem()
        setupOpenChartButton()
    }
    
    func setupOpenChartButton() {
        openChartButton.setImage(UIImage(systemName: "chart.xyaxis.line"), for: .normal)
        openChartButton.setTitle(DefaultTexts.openChartButton, for: .normal)
        openChartButton.setTitleColor(.systemBlue, for: .normal)
        openChartButton.layer.backgroundColor = UIColor.white.cgColor
        openChartButton.layer.cornerRadius = CornerRadius.small
        openChartButton.addTarget(self, action: #selector(handleOpenChartButtonTap), for: .touchUpInside)
    }
    
    func setupInitialLabel() {
        initialInfoLabel.attributedText = centeredAttributedString(
            DefaultTexts.initialInfoLabel,
            fontSize: DefaultSizes.initialLabelFontSize
        )
        initialInfoLabel.sizeToFit()
    }
    
    func setupOpenWalletBarButton() {
        openWalletBarButton.title = DefaultTexts.resetBarButton
        openWalletBarButton.target = self
        openWalletBarButton.image = UIImage(systemName: "wallet.bifold")
        openWalletBarButton.action = #selector(handleOpenWalletBarButton)
    }
    
    func setupNavigationItem() {
        navigationItem.leftBarButtonItem = resetBarButton
        navigationItem.rightBarButtonItems = [chooeseRandomCurrencyBarButton, openWalletBarButton]
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
    
    func setupCommonDealHistoryTableView() {
        commonDealHistoryTableView.register(CommonHistoryCell.self, forCellReuseIdentifier: CommonHistoryCell.identifier)
        commonDealHistoryTableView.dataSource = self
        commonDealHistoryTableView.alpha = .zero
        commonDealHistoryTableView.layer.borderWidth = BorderWidth.thin
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
    
    func addOpenChartButton() {
        view.addSubview(openChartButton)
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
    
    func addCommonDealHistoryTableView() {
        view.addSubview(commonDealHistoryTableView)
    }
    
    // MARK: - Constraints
    func setConstraints() {
        setRunButtonConstraints()
        setTitleLabelConstraints()
        setSuperviewForTitleLabelConstraints()
        setInitialLabelConstraints()
        setCustomerSupportViewConstraints()
        setDealHistoryTableViewConstraints()
        setCommonDealHistoryTableViewConstraints()
        setCurrenciesToChooseStackViewConstraints()
        setOpenChartButtonConstraints()
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
    
    func setOpenChartButtonConstraints() {
        openChartButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            openChartButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ConstraintSpacing.small
            ),
            openChartButton.heightAnchor.constraint(lessThanOrEqualToConstant: DefaultSizes.maximumRunButtonHeight),
            openChartButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
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
                equalTo: openChartButton.bottomAnchor,
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
                equalTo: currencyToChooseStackView.bottomAnchor,
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
    
    func setCommonDealHistoryTableViewConstraints() {
        commonDealHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commonDealHistoryTableView.bottomAnchor.constraint(
                equalTo: runButton.topAnchor,
                constant: -ConstraintSpacing.standard
            ),
            commonDealHistoryTableView.topAnchor.constraint(
                lessThanOrEqualTo: customerSupportView.bottomAnchor,
                constant: ConstraintSpacing.standard
            ),
            commonDealHistoryTableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            commonDealHistoryTableView.trailingAnchor.constraint(
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
    
    func botLongExecution(for bot: Bot) {
        for day in .zero..<BotExecutionConfiguration.daysToRun {
            let startOfTheDay: Date = .now
            for _ in .zero..<Int.random(in: BotExecutionConfiguration.minOperationsPerDay...BotExecutionConfiguration.maxOperationsPerDay) {
                market.updateCurrenciesValues()
                let marketCurrencies = market.getCurrenciesSnapshot()
                bot.updateChosenCurrencies(from: marketCurrencies)
                bot.runOperation()
            }
            let profit = bot.calculateProfitForAPeriod(startDate: startOfTheDay)
            let dayResult = DayResult(day: day, botName: bot.name, income: profit)
            commonHistory.append(dayResult)
        }
    }
    
    func textForCurrencylabel(currency: RandomlyGeneratedCurrency) -> String {
        return "\(currency.name.uppercased()) - \(currency.value.stringWithTwoDecimalPlaces)"
    }
    
    func updateViewFromModel() {
        dealHistoryTableView.reloadData()
        
        commonHistory = commonHistory.sorted { $0.day < $1.day }
        commonDealHistoryTableView.reloadData()
        
        if !commonHistory.isEmpty, commonDealHistoryTableView.alpha == .zero {
            crossDissolveViews(form: initialInfoLabel, to: commonDealHistoryTableView)
        } else if commonHistory.isEmpty, commonDealHistoryTableView.alpha > .zero {
            crossDissolveViews(form: commonDealHistoryTableView, to: initialInfoLabel)
        }
        for index in traderBot.chosenCurrencies.indices {
            currenciesToChoose[index].currencyText = traderBot.chosenCurrencies[index].stringToDisplay
        }
    }
    
    @objc
    func handleRootViewSvipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up , gesture.state == .ended {
            routeToChart()
        }
    }
    
    @objc
    func runButtonTapped() {
        let group = DispatchGroup()
        let bots = [traderBot, botDave, botJerry, botAndy, botDaniel, botSam]
        
        for bot in bots {
            group.enter()
            botsQueue.async { [weak self] in
                self?.botLongExecution(for: bot)
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.updateViewFromModel()
        }
    }
    
    @objc
    func handleChosenCurrencyTap() {
        onOpenFavoriteCurrencies?(market.getArrayOfCurrencies(), traderBot.chosenCurrencies)
    }
    
    @objc
    func handleResetButtonTap() {
        resetBot(chosenCurrencies: traderBot.chosenCurrencies)
        updateViewFromModel()
    }
    
    @objc
    func handleChooseRandomCurrencyTap() {
        var allCurrencies = market.getArrayOfCurrencies()
        for index in traderBot.chosenCurrencies.indices {
            if !allCurrencies.isEmpty {
                let randomIndex = Int.random(in: .zero..<allCurrencies.endIndex)
                let currency = allCurrencies.remove(at: randomIndex)
                traderBot.setCurrencyAsChosen(currency: currency, at: index)
            }
        }
        resetBot(chosenCurrencies: traderBot.chosenCurrencies)
        updateViewFromModel()
    }
    
    @objc
    func handleOpenChartButtonTap() {
        //routeToChart()
        onOpenChart?()
    }
    
    @objc
    func handleOpenWalletBarButton() {
        //routeToWallet()
        onOpenWallet?(market, wallet)
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
            currencies: market.getArrayOfCurrencies(),
            historyHandler: botHistoryHandler,
            wallet: wallet,
            walletHandler: walletHandler,
            amountOfChosenCurrencies: DefaultValues.amountOfCurrenciesToChoose,
            namePostfix: "MAIN"
        )
        for index in chosenCurrencies.indices {
            traderBot.setCurrencyAsChosen(currency: chosenCurrencies[index], at: index)
        }
    }
}

// MARK: - UITableViewDataSource Implementation
extension BotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == dealHistoryTableView {
            return traderBot.getDealHistory().count
        } else {
            return commonHistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == dealHistoryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.identifier) as? DealCell
            cell?.displayedDeal = traderBot.getDealHistory()[indexPath.row]
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommonHistoryCell.identifier) as? CommonHistoryCell
            cell?.displayedResult = commonHistory[indexPath.row]
            return cell ?? UITableViewCell()
        }
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
        //routeToCurrencyConversion()
        onOpenCurrencyConversion?(market.getArrayOfCurrencies(), traderBot.chosenCurrencies)
    }
}

// MARK: - Routing
private extension BotViewController {
    func routeToCurrencyConversion() {
        let conversionViewController = CurrencyConversionViewController(
            currencies: market.getArrayOfCurrencies(),
            chosenCurrencies: traderBot.chosenCurrencies,
            isTimerNeeded: true
        )
        
        conversionViewController.currencyConversionDelegate = self
        conversionViewController.title = "All currencies"
        navigationController?.pushViewController(conversionViewController, animated: true)
    }
    
    func routeToFavoriteCurrencyConversion() {
        let conversionViewController = FavoriteCurrenciesViewController()
        conversionViewController.chosenCurrencies = traderBot.chosenCurrencies
        conversionViewController.currenciesToDisplay = market.getArrayOfCurrencies()
        conversionViewController.favoriteCurrenciesDelegate = self
        present(conversionViewController, animated: true)
    }
    
    func routeToChart() {
        let chartViewController = CurrencyChartViewController()
        present(chartViewController, animated: true)
    }
    
    func routeToWallet() {
        let walletViewController = WalletViewController(
            walletCurrencies: wallet.getCurrenciesOnHandSnapshot(),
            marketCurrencies: market.getArrayOfCurrencies()
        )
        present(walletViewController, animated: true)
    }
    
}

// MARK: - Constants
private extension BotViewController {
    enum DefaultValues {
        static let currenciesToGenerate = 5
        static let amountOfCurrenciesToChoose = 2
    }
    
    enum BotExecutionConfiguration {
        static let minOperationsPerDay = 10
        static let maxOperationsPerDay = 15
        static let daysToRun = 100
    }
    
    enum DefaultSizes {
        static let initialLabelFontSize: CGFloat = 50
        static let titleLabelFontSize: CGFloat = 25
        static let maximumRunButtonHeight: CGFloat = 30
        static let maximumOpenChartButtonHeight: CGFloat = 30
        static let maximumTitleSuperviewHeight: CGFloat = 40
    }
    
    enum DefaultTexts {
        static let runButtonText = "Run Bot"
        static let initialInfoLabel = "No data"
        static let resetBarButton = "Reset"
        static let initialCurrencyValue = "0.00"
        static let openChartButton = "Chart"
        static let chooseRandom = "Randomize"
        static let mainTitle = "Currencies"
    }
}
