//
//  TradingService.swift
//  homework4
//
//  Created by Максим  on 25.04.2026.
//

import Foundation
import Combine

protocol TradingServiceProtocol {
    var wallet: WalletProtocol { get }
    var localCurrencies: [RandomlyGeneratedCurrency] { get }
    var networkCurrencies: [RandomlyGeneratedCurrency]? { get }
    var currencyPair: CurrencyPair { get }
    var offers: [Offer] { get }
    var delegate: TradingServiceDelegate? { get }
    
    func setNewCurrencyPair(newPair: CurrencyPair)
    func updateCurrencies(newCurrencies: [RandomlyGeneratedCurrency])
    func getAllCurrenciesSnapshot() -> [RandomlyGeneratedCurrency]
    func currentOffersSnapshot() -> [Offer]
    func makePurchase(_ offer: Offer, quantity: Double, isCombineUsed: Bool)
    func sortOffersByRate()
    func setDelegate(_ delegate: TradingServiceDelegate)
    func addInitialBalanceForNetworkCurrencies()
    func setNewOffers(_ newOffers: [Offer])
    func updateNetworkCurrencies(isCombineUsed: Bool)
    func generateLocalOffers()
}

protocol TradingServiceDelegate: AnyObject {
    func handleOperationError(error: Error)
    func offersUpdated()
}

enum TradingServiceMode {
    case Local
    case Network
}

final class TradingService: TradingServiceProtocol {
    private(set) var wallet: any WalletProtocol
    private(set) var localCurrencies: [RandomlyGeneratedCurrency]
    private(set) var offers = [Offer]()
    private(set) var networkCurrencies: [RandomlyGeneratedCurrency]?
    private(set) var mode: TradingServiceMode
    private(set) var currencyPair: CurrencyPair {
        didSet {
            updateFilteredOffers()
        }
    }
    
    private var filteredOffers = [Offer]()
    private var cancellables = Set<AnyCancellable>()
    
    private let currencyFetcher: CurrencyFetcherProtocol
    private let walletHandler: WalletHandlerProtocol
    private let lock = NSLock()
    private let isCombineUsed = false
    
    weak var delegate: TradingServiceDelegate?
    
    init(wallet: any WalletProtocol, walletHandler: any WalletHandlerProtocol, localCurrencies: [RandomlyGeneratedCurrency], currencyFetcher: CurrencyFetcherProtocol) {
        self.wallet = wallet
        self.walletHandler = walletHandler
        self.localCurrencies = localCurrencies
        self.mode = .Local
        self.currencyFetcher = currencyFetcher
        
        let placeholderCurrency = RandomlyGeneratedCurrency.generatePlaceholderCurrency()
        self.currencyPair = CurrencyPair(firstCurrency: placeholderCurrency, secondCurrency: placeholderCurrency)
        
        generateLocalOffers()
        updateNetworkCurrencies(isCombineUsed: isCombineUsed)
    }
    
    func setNewOffers(_ newOffers: [Offer]) {
        offers = newOffers
    }
    
    func updateNetworkCurrencies(isCombineUsed: Bool) {
        if isCombineUsed {
            updateAvalibleNetworkCurrenciesWithCombine()
        } else {
            updateAvalibleNetworkCurrencies()
        }
    }
    
    func addInitialBalanceForNetworkCurrencies() {
        guard let networkCurrencies else { return }
        for currency in networkCurrencies {
            walletHandler.addCurrency(currency, quantity: 10000, wallet: wallet)
        }
    }
    
    func setDelegate(_ delegate: any TradingServiceDelegate) {
        lock.lock()
        defer { lock.unlock() }
        self.delegate = delegate
    }
    
    func sortOffersByRate() {
        lock.lock()
        defer { lock.unlock() }
        offers = offers.sorted { $0.exchangeRate >= $1.exchangeRate }
    }
    
    func getAllCurrenciesSnapshot() -> [RandomlyGeneratedCurrency] {
        return localCurrencies + (networkCurrencies ?? [RandomlyGeneratedCurrency]())
    }
    
    func currentOffersSnapshot() -> [Offer] {
        var offerArray = offers
        if currencyPair.firstCurrency.id != UUID.empty || currencyPair.secondCurrency.id != UUID.empty {
            offerArray = filteredOffers
        }
        return offerArray
    }
    
    func updateAvalibleNetworkCurrencies() {
        currencyFetcher.fetchUniqueCurrenicesAndPairs(completionHandler: ) { [weak self] result in
            switch result {
            case .success(let fetcherResponse):
                self?.setNewNetworkCurrencyOffers(pairs: fetcherResponse.currencyPairs)
                self?.setNewNetworkCurrencuies(newCurrencies: fetcherResponse.uniqueCurrencies)
                self?.delegate?.offersUpdated()
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.handleOperationError(error: error)
                }
            }
        }
    }
    
    func updateAvalibleNetworkCurrenciesWithCombine() {
        currencyFetcher.fetchUniqueCurrenicesAndPairsWithCombine()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.delegate?.handleOperationError(error: error)
                default:
                    break
                }
            }, receiveValue: { [weak self] result in
                self?.setNewNetworkCurrencyOffers(pairs: result.currencyPairs)
                self?.setNewNetworkCurrencuies(newCurrencies: result.uniqueCurrencies)
                self?.delegate?.offersUpdated()
            })
            .store(in: &cancellables)
    }
    
    func makePurchase(_ offer: Offer, quantity: Double, isCombineUsed: Bool = false) {
        let quantityToSell = quantity / offer.exchangeRate
        do {
            try walletHandler.withdrawCurrency(offer.currencyPair.firstCurrency, quantity: quantityToSell, wallet: wallet)
        } catch {
            self.delegate?.handleOperationError(error: error)
            return
        }
        walletHandler.addCurrency(offer.currencyPair.secondCurrency, quantity: quantity, wallet: wallet)
        if isCombineUsed {
            sendPurchaseOfferWithCombine(offer: offer, quantityToBuy: quantity, quantityToSell: quantityToSell)
        } else {
            sendPurchaseOffer(offer: offer, quantityToBuy: quantity, quantityToSell: quantityToSell)
        }
    }
    
    func updateCurrencies(newCurrencies: [RandomlyGeneratedCurrency]) {
        let newLocalCurrencies = newCurrencies.filter { !$0.isFromNet }
        let newNetworkCurrencies = newCurrencies.filter { $0.isFromNet }
        
        setNewLocalCurrencuies(newCurrencies: newLocalCurrencies)
        setNewNetworkCurrencuies(newCurrencies: newNetworkCurrencies)
    }
    
    func setNewCurrencyPair(newPair: CurrencyPair) {
        lock.lock()
        defer { lock.unlock() }
        currencyPair = newPair
    }
    
    func generateLocalOffers() {
        lock.lock()
        defer { lock.unlock() }
        offers = offers.filter { $0.isNetworkOffer }
        for firstCurrency in localCurrencies {
            for secondCurrency in localCurrencies {
                if firstCurrency.id == secondCurrency.id {
                    continue
                }
                let pair = CurrencyPair(firstCurrency: firstCurrency, secondCurrency: secondCurrency)
                let offer = Offer(id: UUID(),currencyPair: pair)
                offers.append(offer)
            }
        }
    }
}

// MARK: - Private Methods
private extension TradingService {
    func setNewNetworkCurrencuies(newCurrencies: [RandomlyGeneratedCurrency]) {
        lock.lock()
        defer { lock.unlock() }
        networkCurrencies = newCurrencies
    }
    
    func sendPurchaseOffer(offer: Offer, quantityToBuy: Double, quantityToSell: Double) {
        currencyFetcher.sendPurchaseOffer(offer: offer, quantity: quantityToBuy) { [self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.handleOperationError(error: error)
                }
                do {
                    try self.walletHandler.withdrawCurrency(offer.currencyPair.secondCurrency, quantity: quantityToSell, wallet: self.wallet)
                    self.walletHandler.addCurrency(offer.currencyPair.firstCurrency, quantity: quantityToSell, wallet: self.wallet)
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.handleOperationError(error: error)
                    }
                }
            default:
                let newFirstCurrencyQuantity = offer.currencyPair.firstCurrency.quantity + quantityToSell
                let newSecondCurrencyQuantity = offer.currencyPair.secondCurrency.quantity - quantityToBuy
                DispatchQueue.main.async {
                    self.updateOffer(
                        offerToUpdate: offer,
                        newFirstCurrencyQuantity: newFirstCurrencyQuantity,
                        newSecondCurrencyQuantity: newSecondCurrencyQuantity
                    )
                }
            }
        }
    }
    
    func sendPurchaseOfferWithCombine(offer: Offer, quantityToBuy: Double, quantityToSell: Double) {
        currencyFetcher.sendPurchaseOfferWithCombine(offer: offer, quantity: quantityToBuy)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    self.delegate?.handleOperationError(error: error)
                    do {
                        try self.walletHandler.withdrawCurrency(offer.currencyPair.secondCurrency, quantity: quantityToSell, wallet: self.wallet)
                        self.walletHandler.addCurrency(offer.currencyPair.firstCurrency, quantity: quantityToSell, wallet: self.wallet)
                    } catch {
                        self.delegate?.handleOperationError(error: error)
                    }
                default:
                    break
                }
            }, receiveValue: { [weak self] _ in
                let newFirstCurrencyQuantity = offer.currencyPair.firstCurrency.quantity + quantityToSell
                let newSecondCurrencyQuantity = offer.currencyPair.secondCurrency.quantity - quantityToBuy
                
                self?.updateOffer(
                    offerToUpdate: offer,
                    newFirstCurrencyQuantity: newFirstCurrencyQuantity,
                    newSecondCurrencyQuantity: newSecondCurrencyQuantity
                )
            }).store(in: &cancellables)
    }
    
    func updateOffer(offerToUpdate offer: Offer, newFirstCurrencyQuantity: Double, newSecondCurrencyQuantity: Double) {
        lock.lock()
        defer { lock.unlock() }
        if let index = offers.firstIndex(where: { $0.id == offer.id }) {
            let newOffer = Offer.changeQuantityForCurrencies(
                offer: offer,
                firstCurrencyQuantity: newFirstCurrencyQuantity,
                secondCurrencyQuantity: newSecondCurrencyQuantity
            )
            offers[index] = newOffer
        }
        delegate?.offersUpdated()
    }
    
    func updateFilteredOffers() {
        var suitableOffers = offers
        if currencyPair.firstCurrency.id != UUID.empty {
            suitableOffers = suitableOffers.filter { $0.currencyPair.firstCurrency.id == currencyPair.firstCurrency.id }
        }
        if currencyPair.secondCurrency.id != UUID.empty {
            suitableOffers = suitableOffers.filter { $0.currencyPair.secondCurrency.id == currencyPair.secondCurrency.id }
        }
        filteredOffers = suitableOffers
        delegate?.offersUpdated()
    }
    
    func setNewNetworkCurrencyOffers(pairs: [CurrencyPair]) {
        lock.lock()
        defer { lock.unlock() }
        offers = offers.filter { !$0.isNetworkOffer }
        for pair in pairs {
            let offer = Offer(id: UUID(), currencyPair: pair, isNetworkOffer: true)
            offers.append(offer)
        }
    }
    
    func setNewLocalCurrencuies(newCurrencies: [RandomlyGeneratedCurrency]) {
        lock.lock()
        defer { lock.unlock() }
        localCurrencies = newCurrencies
    }
}
