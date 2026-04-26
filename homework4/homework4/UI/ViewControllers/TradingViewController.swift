//
//  TradingViewController.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation
import UIKit

final class TradingViewController: UIViewController {
    private let currencyToChooseStackView = UIStackView()
    private let tradingService: TradingServiceProtocol
    private let openWalletBarButton = UIBarButtonItem()
    private let offersTableView = UITableView()
    
    private var currenciesToChoose = [CurrencyToChooseView]()
    private var tappedOffer: Offer?
    private var selectedCurrencyToChooseIndex: Int? {
        return currenciesToChoose.firstIndex(where: { $0.isChosen })
    }
    
    private var chosenCurrencies: [RandomlyGeneratedCurrency]
    
    init(localCurrencies: [RandomlyGeneratedCurrency]) {
        self.tradingService = TradingService(
            wallet: Wallet(currencies: localCurrencies),
            walletHandler: WalletHandler(),
            localCurrencies: localCurrencies,
            currencyFetcher: AlorCurrencyFetcher()
        )
        
        let firstCurrency = tradingService.currencyPair.firstCurrency
        let secondCurrency = tradingService.currencyPair.secondCurrency
        self.chosenCurrencies = [firstCurrency, secondCurrency]
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTradingService()
        addSubviews()
        setupUI()
        setConstraints()
        tradingService.sortOffersByRate()
        offersTableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

// MARK: - Private UI Methods
private extension TradingViewController {
    func setupTradingService() {
        tradingService.setDelegate(self)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.systemYellow
        
        setupOffersTableView()
        setupOpenWalletBarButton()
        setupNavigationItem()
        setupCurrenciesToChoose()
        setupCurrenciesToChooseStackView()
    }
    
    func addSubviews() {
        addCurrenciesToChooseStackView()
        addCurrenciesToChoose()
        addOffersTableView()
    }
    
    func setConstraints() {
        setCurrenciesToChooseStackViewConstraints()
        setOfferTableViewConstraints()
    }
    
    func setupNavigationItem() {
        navigationItem.rightBarButtonItems = [openWalletBarButton]
    }
    
    func setupOpenWalletBarButton() {
        openWalletBarButton.title = .walletBarButton
        openWalletBarButton.target = self
        openWalletBarButton.image = UIImage(systemName: "wallet.bifold")
        openWalletBarButton.action = #selector(handleOpenWalletBarButton)
    }
    
    func setupOffersTableView() {
        offersTableView.register(OfferCell.self, forCellReuseIdentifier: OfferCell.identifier)
        offersTableView.dataSource = self
        offersTableView.delegate = self
        offersTableView.layer.borderWidth = BorderWidth.thin
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
    
    func setupCurrenciesToChooseStackView() {
        currencyToChooseStackView.axis = .horizontal
        currencyToChooseStackView.spacing = StackViewSpacing.small
        currencyToChooseStackView.distribution = .fillEqually
    }
    
    func addCurrenciesToChooseStackView() {
        view.addSubview(currencyToChooseStackView)
    }
    
    func addCurrenciesToChoose() {
        for _ in .zero..<DefaultValues.amountOfCurrenciesToChoose {
            let currencyView = CurrencyToChooseView()
            currenciesToChoose.append(currencyView)
            currencyToChooseStackView.addArrangedSubview(currencyView)
        }
    }
    
    func addOffersTableView() {
        view.addSubview(offersTableView)
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
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ConstraintSpacing.standard
            )
        ])
    }
    
    func setOfferTableViewConstraints() {
        offersTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            offersTableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ConstraintSpacing.standard
            ),
            offersTableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -ConstraintSpacing.standard
            ),
            offersTableView.topAnchor.constraint(
                equalTo: currencyToChooseStackView.bottomAnchor,
                constant: ConstraintSpacing.standard
            ),
            offersTableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -ConstraintSpacing.standard
            )
        ])
    }
    
    func updateViewFromModel() {
        offersTableView.reloadData()
        
        currenciesToChoose[0].currencyText = tradingService.currencyPair.firstCurrency.stringToDisplay
        currenciesToChoose[1].currencyText = tradingService.currencyPair.secondCurrency.stringToDisplay
    }
    
    func configureAndShowConfimationWondow() {
        let confirmationWindow = UIAlertController(
            title: "Confirm purchase",
            message: "Please input needed amount",
            preferredStyle: .alert
        )
        
        guard let offer = tappedOffer else {return}
        confirmationWindow.addTextField {
            $0.placeholder = String(offer.currencyPair.secondCurrency.quantity)
            $0.keyboardType = .numberPad
            $0.delegate = self
            $0.autocorrectionType = .no
            $0.textContentType = .none
            $0.autocapitalizationType = .none
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if let text = confirmationWindow.textFields?.first?.text,
               !text.isEmpty,
               let tappedOffer = self.tappedOffer {
                let quantity = Double(text) ?? .zero
                self.tradingService.makePurchase(tappedOffer, quantity: quantity)
                self.tappedOffer = nil
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        confirmationWindow.addAction(confirmAction)
        confirmationWindow.addAction(cancelAction)
        present(confirmationWindow, animated: true)
    }
    
    func configureAndShowErrorWindow(error: Error) {
        var text: String
        
        switch error {
        case APIRequestError.WrongURL:
            text = "Wrong URL"
        case WalletError.notEnoughtFounds:
            text = "Not enough founds"
        case APIRequestError.DecocingError:
            text = "Something went wrong, try again later"
        case NetworkError.NoIntertnetConnection:
            text = "No intetnet connection"
        case APIRequestError.ClientError:
            text = "Insufficient privileges, action denied"
        default:
            text = "Oops... Something went wrong"
        }
        
        let errorWindow = UIAlertController(
            title: "Error",
            message: text,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        errorWindow.addAction(cancelAction)
        
        present(errorWindow, animated: true)
    }
}

// MARK: - UITextFieldDelegate Implemenatanion
extension TradingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let decimalCharacters = CharacterSet(charactersIn: .allDecimalCharacters)
        let characterSet = CharacterSet(charactersIn: string)
        return decimalCharacters.isSuperset(of: characterSet)
    }
}

// MARK: - Action Handlers
private extension TradingViewController {
    @objc
    func handleOpenWalletBarButton() {
        routeToWallet()
    }
    
    @objc
    func handleChosenCurrencyTap() {
        routeToFavoriteCurrencyConversion()
    }
}

// MARK: - Routing
private extension TradingViewController {
    func routeToWallet() {
        let walletViewController = WalletViewController(
            walletCurrencies: tradingService.wallet.getCurrenciesOnHandSnapshot(),
            marketCurrencies: tradingService.getAllCurrenciesSnapshot()
        )
        present(walletViewController, animated: true)
    }
    
    func routeToFavoriteCurrencyConversion() {
        let chosenCurrencies = [tradingService.currencyPair.firstCurrency, tradingService.currencyPair.secondCurrency]
        let conversionViewController = CurrencyConversionViewController(currencies: tradingService.getAllCurrenciesSnapshot(), chosenCurrencies: chosenCurrencies)
        conversionViewController.currencyConversionDelegate = self
        present(conversionViewController, animated: true)
    }
}

// MARK: - FavoriteCurrenciesDelegate And CurrencyConversionDelegate Implementation
extension TradingViewController: CurrencyConversionDelegate {
    func currencyChosen(chosenCurrencies: [RandomlyGeneratedCurrency]) {
        let newCurrecnyPair = CurrencyPair(firstCurrency: chosenCurrencies[0], secondCurrency: chosenCurrencies[1])
        tradingService.setNewCurrencyPair(newPair: newCurrecnyPair)
        updateViewFromModel()
    }
    
    func currencyConversionUpdated(allCurrencies: [RandomlyGeneratedCurrency], chosenCurrencies: [RandomlyGeneratedCurrency]) {
        let newCurrecnyPair = CurrencyPair(firstCurrency: chosenCurrencies[0], secondCurrency: chosenCurrencies[1])
        tradingService.setNewCurrencyPair(newPair: newCurrecnyPair)
        tradingService.updateCurrencies(newCurrencies: allCurrencies)
        updateViewFromModel()
    }
}

// MARK: - UITableViewDelegate Implementation
extension TradingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tappedOffer = tradingService.currentOffersSnapshot()[indexPath.row]
        configureAndShowConfimationWondow()
    }
}

// MARK: - UITableViewDataSource Implementation
extension TradingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tradingService.currentOffersSnapshot().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OfferCell.identifier) as? OfferCell
        cell?.displayedOffer = tradingService.currentOffersSnapshot()[indexPath.row]
        return cell ?? UITableViewCell()
    }
}

// MARK: - TradigServiceDelegate Implementation
extension TradingViewController: TradingServiceDelegate {
    func offersUpdated() {
        updateViewFromModel()
    }
    
    func handleOperationError(error: any Error) {
        configureAndShowErrorWindow(error: error)
    }
}

// MARK: - Constants
private extension TradingViewController {
    enum DefaultValues {
        static let amountOfCurrenciesToChoose = 2
    }
}

// MARK: - String Constants
private extension String {
    static let walletBarButton = "Wallet"
}
