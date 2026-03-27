//
//  ViewController.swift
//  homework4
//
//  Created by Максим  on 17.03.2026.
//

import UIKit

final class ViewController: UIViewController {
    private lazy var traderBot = Bot(logger: viewLogger)
    private lazy var viewLogger = TextViewLogger(textView: botOutput)
    private var market = Market()
    private let runButton = UIButton()
    private let botOutput = UITextView()
    private var currencyLabels = [UILabel]()
    private let currencyStackView = UIStackView()
    private let phoneImage = UIImage()
    private let superviewForLabel = UIView()
    private let labelForSuperview = UILabel()
    private let customerSupportView = SupportInformationView()
    private let initialInfoLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
}

// MARK: - Private Methods
private extension ViewController {
    func initViews() {
        view.backgroundColor = .systemYellow
        addInitialLabel()
        addRunButton()
        addTextView()
        addCurrencyInfoViews()
        addViewWithSubview()
        addCustomerSupportView()
        setConstraints()
    }
    
    func addInitialLabel() {
        initialInfoLabel.attributedText = centeredAttributedString(defaultTexts.initialInfoLabel, fontSize: 50)
        initialInfoLabel.sizeToFit()
        initialInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(initialInfoLabel)
    }
    
    func addViewWithSubview() {
        superviewForLabel.translatesAutoresizingMaskIntoConstraints = false
        superviewForLabel.backgroundColor = .systemRed
        superviewForLabel.alpha = 0.8
        labelForSuperview.attributedText = centeredAttributedString(defaultTexts.mainTitle, fontSize: 25)
        labelForSuperview.sizeToFit()
        labelForSuperview.textAlignment = .center
        superviewForLabel.addSubview(labelForSuperview)
        view.addSubview(superviewForLabel)
    }
    
    func addCurrencyInfoViews() {
        currencyStackView.spacing = CGFloat(5)
        currencyStackView.axis = .vertical
        currencyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for currencyName in Currency.CurrencyName.allCases {
            let currencyLabel = UILabel()
            currencyLabel.text = "\(currencyName.rawValue.uppercased()) - \(defaultTexts.initialCurrencyValue)"
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
    
    func addTextView() {
        botOutput.layer.borderColor = UIColor.systemGray.cgColor
        botOutput.layer.borderWidth = 0.5
        botOutput.isEditable = false
        botOutput.alpha = 0
        view.addSubview(botOutput)
        botOutput.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addRunButton() {
        view.addSubview(runButton)
        runButton.setTitle(defaultTexts.runButtonText, for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.titleLabel?.textColor = .white
        runButton.layer.cornerRadius = CGFloat(10)
        runButton.addTarget(self, action: #selector(runButtonTapped), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraints
    func setConstraints() {
        setRunButtonConstraints()
        setTextViewConstraints()
        setCurrencyStackViewConstraints()
        setLabelForSuperviewConstraints()
        setViewForLabelConstraints()
        setInitialLabelConstraints()
        setCustomerSupportViewConstraints()
    }
    
    func setInitialLabelConstraints() {
        NSLayoutConstraint.activate([
            initialInfoLabel.topAnchor.constraint(equalTo: botOutput.topAnchor),
            initialInfoLabel.bottomAnchor.constraint(equalTo: botOutput.bottomAnchor),
            initialInfoLabel.leadingAnchor.constraint(equalTo: botOutput.leadingAnchor),
            initialInfoLabel.trailingAnchor.constraint(equalTo: botOutput.trailingAnchor),
        ])
    }
    
    func setRunButtonConstraints() {
        NSLayoutConstraint.activate([
            runButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            runButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setTextViewConstraints() {
        NSLayoutConstraint.activate([
            botOutput.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            botOutput.bottomAnchor.constraint(equalTo: runButton.topAnchor, constant: -16),
            botOutput.topAnchor.constraint(lessThanOrEqualTo: customerSupportView.bottomAnchor, constant: 64),
            botOutput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            botOutput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func setCurrencyStackViewConstraints() {
        NSLayoutConstraint.activate([
            currencyStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            currencyStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            currencyStackView.topAnchor.constraint(equalTo: superviewForLabel.bottomAnchor, constant: 16)
        ])
    }
    
    func setLabelForSuperviewConstraints() {
        NSLayoutConstraint.activate([
            labelForSuperview.topAnchor.constraint(equalTo: superviewForLabel.topAnchor),
            labelForSuperview.bottomAnchor.constraint(equalTo: superviewForLabel.bottomAnchor),
            labelForSuperview.trailingAnchor.constraint(equalTo: superviewForLabel.trailingAnchor),
            labelForSuperview.leadingAnchor.constraint(equalTo: superviewForLabel.leadingAnchor),
            labelForSuperview.centerXAnchor.constraint(equalTo: superviewForLabel.centerXAnchor)
        ])
    }
    
    func setViewForLabelConstraints() {
        NSLayoutConstraint.activate([
            superviewForLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            superviewForLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func setCustomerSupportViewConstraints() {
        NSLayoutConstraint.activate([
            customerSupportView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            customerSupportView.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            customerSupportView.topAnchor.constraint(equalTo: currencyStackView.bottomAnchor, constant: 16),
            customerSupportView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func textForCurrencylabel(currency: Currency) -> String {
        return "\(currency.name.rawValue.uppercased()) - \(String(format: "%.2f", currency.value))"
    }
    
    func updateViewFromModel() {
        for index in market.currencies.indices {
            let currency = market.currencies[index]
            currencyLabels[index].text = textForCurrencylabel(currency: currency)
        }
        if traderBot.decisionsMade > 0, botOutput.alpha == 0 {
            crossDissolveViews(form: initialInfoLabel, to: botOutput)
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
                oldView.alpha = 0
                newView.alpha = 1
            },
            completion: nil
        )
    }
}

// MARK: - Constants
private extension ViewController {
    struct defaultTexts {
        static let runButtonText = "Run Bot"
        static let initialInfoLabel = "No data"
        static let initialCurrencyValue = "0.00"
        static let mainTitle = "Currencies"
    }
}
