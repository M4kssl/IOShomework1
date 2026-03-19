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
    private let customerSupportLabel = UILabel()
    private let customerSupportPicure = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
}

extension ViewController {
    func initViews() {
        view.backgroundColor = .systemYellow
        addRunButton()
        addTextView()
        addCurrencyInfoViews()
        addViewWithSubview()
        addCustomerSupportInfo()
        setConstraints()
    }
    
    private func addViewWithSubview() {
        let viewWidth = view.frame.width / 2 + 40
        let viewHeight = CGFloat(40)
        let xPoint = view.safeAreaLayoutGuide.layoutFrame.midX - viewWidth / 2
        let yPoint = CGFloat(20)
        superviewForLabel.frame = CGRect(x: xPoint, y: yPoint, width: viewWidth, height: viewHeight)
        superviewForLabel.translatesAutoresizingMaskIntoConstraints = false
        superviewForLabel.backgroundColor = .systemRed
        superviewForLabel.alpha = 0.8
        labelForSuperview.attributedText = centeredAttributedString("Currencies", fontSize: 25)
        labelForSuperview.sizeToFit()
        labelForSuperview.textAlignment = .center
        superviewForLabel.addSubview(labelForSuperview)
        view.addSubview(superviewForLabel)
    }
    
    private func addCurrencyInfoViews() {
        currencyStackView.spacing = CGFloat(5)
        currencyStackView.axis = .vertical
        currencyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for currencyName in Currency.CurrencyName.allCases {
            let currencyLabel = UILabel()
            currencyLabel.text = "\(currencyName.rawValue.uppercased()) - 0.00"
            currencyLabel.translatesAutoresizingMaskIntoConstraints = false
            currencyLabels.append(currencyLabel)
            currencyStackView.addArrangedSubview(currencyLabel)
        }
        view.addSubview(currencyStackView)
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .headline).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font)
        let paragrapthStyle = NSMutableParagraphStyle()
        paragrapthStyle.alignment = .center
        let attributedString = NSAttributedString(string: string, attributes: [.paragraphStyle: paragrapthStyle, .font:font])
        return attributedString
    }
    
    private func addCustomerSupportInfo() {
        customerSupportLabel.text = "You can call oue customer support:\n +123456789"
        customerSupportLabel.translatesAutoresizingMaskIntoConstraints = false
        customerSupportLabel.numberOfLines = 0
        view.addSubview(customerSupportLabel)
        customerSupportPicure.image = UIImage(named: "phone")
        customerSupportPicure.contentMode = .scaleAspectFit
        customerSupportPicure.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customerSupportPicure)
    }
    
    private func addTextView() {
        botOutput.layer.borderColor = UIColor.systemGray.cgColor
        botOutput.layer.borderWidth = 0.5
        botOutput.isEditable = false
        view.addSubview(botOutput)
        botOutput.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addRunButton() {
        view.addSubview(runButton)
        runButton.setTitle("Run Bot", for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.titleLabel?.textColor = .white
        runButton.layer.cornerRadius = CGFloat(10)
        runButton.addTarget(self, action: #selector(runButtonTapped), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints() {
        setRunButtonConstraints()
        setTextViewConstraints()
        setCurrencyStackViewConstraints()
        setLabelForSuperviewConstraints()
        setViewForLabelConstraints()
        setCustomerSupportImageConstraints()
        setCustomerSupportLabelConstraints()
    }
    
    private func setRunButtonConstraints() {
        NSLayoutConstraint.activate([
            runButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            runButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 120),
            runButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -120)
        ])
    }
    
    private func setTextViewConstraints() {
        NSLayoutConstraint.activate([
            botOutput.heightAnchor.constraint(greaterThanOrEqualToConstant: 250),
            botOutput.bottomAnchor.constraint(equalTo: runButton.topAnchor, constant: -20),
            botOutput.topAnchor.constraint(equalTo: customerSupportPicure.bottomAnchor, constant: 20),
            botOutput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            botOutput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func setCurrencyStackViewConstraints() {
        NSLayoutConstraint.activate([
            currencyStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            currencyStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            currencyStackView.topAnchor.constraint(equalTo: superviewForLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func setLabelForSuperviewConstraints() {
        NSLayoutConstraint.activate([
            labelForSuperview.topAnchor.constraint(equalTo: superviewForLabel.topAnchor, constant: 2),
            labelForSuperview.bottomAnchor.constraint(equalTo: superviewForLabel.bottomAnchor, constant: 2),
            labelForSuperview.centerXAnchor.constraint(equalTo: superviewForLabel.centerXAnchor)
        ])
    }
    
    private func setViewForLabelConstraints() {
        NSLayoutConstraint.activate([
            superviewForLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            superviewForLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func setCustomerSupportImageConstraints() {
        NSLayoutConstraint.activate([
            customerSupportPicure.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            customerSupportPicure.heightAnchor.constraint(lessThanOrEqualToConstant: 150),
            customerSupportPicure.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            customerSupportPicure.leadingAnchor.constraint(equalTo: customerSupportLabel.trailingAnchor, constant: 20),
            customerSupportPicure.topAnchor.constraint(equalTo: currencyStackView.bottomAnchor, constant: 20),
            customerSupportPicure.bottomAnchor.constraint(equalTo: botOutput.topAnchor, constant: -20)
        ])
    }
    
    private func setCustomerSupportLabelConstraints() {
        NSLayoutConstraint.activate([
            customerSupportLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            customerSupportLabel.trailingAnchor.constraint(equalTo: customerSupportLabel.leadingAnchor, constant: -20),
            customerSupportLabel.topAnchor.constraint(equalTo: currencyStackView.bottomAnchor, constant: 20),
            customerSupportLabel.bottomAnchor.constraint(equalTo: botOutput.topAnchor, constant: -20)
        ])
    }
    
    private func textForCurrencylabel(currency: Currency) -> String {
        return "\(currency.name.rawValue.uppercased()) - \(String(format: "%.2f", currency.value))"
    }
    
    private func updateViewFromModel() {
        for index in market.currencies.indices {
            let currency = market.currencies[index]
            currencyLabels[index].text = textForCurrencylabel(currency: currency)
        }
    }
    
    @objc
    private func runButtonTapped() {
        market.updateCurrenciesValues()
        for currency in market.currencies {
            let action = traderBot.decideOnAction(for: currency)
            let request = traderBot.formARequestForMarket(toMake: action, for: currency)
            let response = market.processRequestAndFormAResponse(request)
            traderBot.processMarketResponse(response)
        }
        updateViewFromModel()
    }
}
