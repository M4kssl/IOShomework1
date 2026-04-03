//
//  ViewController.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import UIKit

final class BotViewController: UIViewController {
    private lazy var traderBot = Bot(historyhandler: botHistoryHandler)
    private lazy var botHistoryHandler = BotHistoryHandler()
    private var market = Market()
    private let runButton = UIButton()
    private var currencyLabels = [UILabel]()
    private let currencyStackView = UIStackView()
    private let phoneImage = UIImage()
    private let superviewFortTitleLabel = UIView()
    private let titleLabel = UILabel()
    private let customerSupportView = SupportInformationView()
    private let initialInfoLabel = UILabel()
    private let dealHistoryTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
}

// MARK: - Private Methods
private extension BotViewController {
    func initViews() {
        view.backgroundColor = .systemYellow
        addInitialLabel()
        addRunButton()
        addDealHistoryTableView()
        addCurrencyInfoViews()
        addViewWithSubview()
        addCustomerSupportView()
        setConstraints()
    }
    
    func addInitialLabel() {
        initialInfoLabel.attributedText = centeredAttributedString(
            DefaultTexts.initialInfoLabel,
            fontSize: DefaultSizes.initialLabelFontSize)
        initialInfoLabel.sizeToFit()
        initialInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(initialInfoLabel)
    }
    
    func addViewWithSubview() {
        superviewFortTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        superviewFortTitleLabel.backgroundColor = .systemRed
        titleLabel.attributedText = centeredAttributedString(
            DefaultTexts.mainTitle,
            fontSize: DefaultSizes.titleLabelFontSize
        )
        titleLabel.sizeToFit()
        titleLabel.textAlignment = .center
        superviewFortTitleLabel.addSubview(titleLabel)
        view.addSubview(superviewFortTitleLabel)
    }
    
    func addCurrencyInfoViews() {
        currencyStackView.spacing = StackViewSpacing.small
        currencyStackView.axis = .vertical
        currencyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for currencyName in Currency.CurrencyName.allCases {
            let currencyLabel = UILabel()
            currencyLabel.text = "\(currencyName.rawValue.uppercased()) - \(DefaultTexts.initialCurrencyValue)"
            currencyLabel.translatesAutoresizingMaskIntoConstraints = false
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
        runButton.setTitle(DefaultTexts.runButtonText, for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.titleLabel?.textColor = .white
        runButton.layer.cornerRadius = CornerRadius.standard
        runButton.addTarget(self, action: #selector(runButtonTapped), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addDealHistoryTableView() {
        view.addSubview(dealHistoryTableView)
        dealHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        dealHistoryTableView.register(DealCell.self, forCellReuseIdentifier: DealCell.identifier)
        dealHistoryTableView.dataSource = self
        dealHistoryTableView.alpha = .zero
        dealHistoryTableView.layer.borderWidth = BorderWidth.thin
    }
    
    // MARK: - constraints
    func setConstraints() {
        setRunButtonConstraints()
        setCurrencyStackViewConstraints()
        settitleLabelConstraints()
        setViewForLabelConstraints()
        setInitialLabelConstraints()
        setCustomerSupportViewConstraints()
        setDealHistoryTableViewConstraints()
    }
    
    func setInitialLabelConstraints() {
        NSLayoutConstraint.activate([
            initialInfoLabel.topAnchor.constraint(equalTo: dealHistoryTableView.topAnchor),
            initialInfoLabel.bottomAnchor.constraint(equalTo: dealHistoryTableView.bottomAnchor),
            initialInfoLabel.leadingAnchor.constraint(equalTo: dealHistoryTableView.leadingAnchor),
            initialInfoLabel.trailingAnchor.constraint(equalTo: dealHistoryTableView.trailingAnchor),
        ])
    }
    
    func setRunButtonConstraints() {
        NSLayoutConstraint.activate([
            runButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -ConstraintSpacing.standard
            ),
            runButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setCurrencyStackViewConstraints() {
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
                equalTo: superviewFortTitleLabel.bottomAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }
    
    func settitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: superviewFortTitleLabel.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: superviewFortTitleLabel.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: superviewFortTitleLabel.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: superviewFortTitleLabel.leadingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: superviewFortTitleLabel.centerXAnchor)
        ])
    }
    
    func setViewForLabelConstraints() {
        NSLayoutConstraint.activate([
            superviewFortTitleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ConstraintSpacing.standard
            ),
            superviewFortTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func setCustomerSupportViewConstraints() {
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
                constant: ConstraintSpacing.standard
            ),
            customerSupportView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func setDealHistoryTableViewConstraints() {
        NSLayoutConstraint.activate([
            dealHistoryTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: DefaultSizes.minimalTabelViewSize),
            dealHistoryTableView.bottomAnchor.constraint(
                equalTo: runButton.topAnchor,
                constant: -ConstraintSpacing.standard
            ),
            dealHistoryTableView.topAnchor.constraint(
                lessThanOrEqualTo: customerSupportView.bottomAnchor,
                constant: ConstraintSpacing.extraLarge
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
    
    func textForCurrencylabel(currency: Currency) -> String {
        return "\(currency.name.rawValue.uppercased()) - \(currency.value.stringWithTwoDecimalPlaces)"
    }
    
    func updateViewFromModel() {
        for index in market.currencies.indices {
            let currency = market.currencies[index]
            currencyLabels[index].text = textForCurrencylabel(currency: currency)
        }
        dealHistoryTableView.reloadData()
        
        if traderBot.decisionsMade > .zero, dealHistoryTableView.alpha == .zero {
            crossDissolveViews(form: initialInfoLabel, to: dealHistoryTableView)
        }
    }
    
    @objc
    func runButtonTapped() {
        market.updateCurrenciesValues()
        for currency in market.currencies {
            let action = traderBot.decideOnAction(for: currency)
            let request = traderBot.formARequestForMarket(toMake: action, for: currency)
            let response = market.processRequestAndFormAResponse(request)
            traderBot.processMarketResponse(response)
        }
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
    struct DefaultSizes {
        static let minimalTabelViewSize = CGFloat(200)
        static let initialLabelFontSize = CGFloat(50)
        static let titleLabelFontSize = CGFloat(25)
    }
    
    struct DefaultTexts {
        static let runButtonText = "Run Bot"
        static let initialInfoLabel = "No data"
        static let initialCurrencyValue = "0.00"
        static let mainTitle = "Currencies"
    }
}
