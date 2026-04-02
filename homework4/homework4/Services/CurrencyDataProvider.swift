//
//  CurrencyDataGenerator.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//

import Foundation
import UIKit

enum CurrencyType: String, CaseIterable {
    case fiat
    case crypto
}

protocol CurrencyDelegatePrtocol: AnyObject {
    func currencyChosen(_ currency: RandomlyGeneratedCurrency)
}

protocol CurrencyDataProviderProtocol {
    var allCurrencies: [RandomlyGeneratedCurrency] { get }
    var chosenCurrencies: [RandomlyGeneratedCurrency] { get }
    var filteredCurrencies: [RandomlyGeneratedCurrency] { get }
    var delegate: CurrencyDelegatePrtocol? { get set }
    func generateNewValues()
    func chooseCurrency(currency: RandomlyGeneratedCurrency, chosenCurrenciesIndex: Int)
    func filterCurrenciesByType(_ currencyType: CurrencyType)
    func clearFilters()
    func convertCurrency(atChosenCurrencyIndex fromIndex: Int, toChosenCurrencyIndex toIndex: Int) -> Double

}

final class CurrencyDataProvider: NSObject, CurrencyDataProviderProtocol {
    private var currencyTypeFilteredBy: CurrencyType?
    
    private(set) var allCurrencies = [RandomlyGeneratedCurrency]()
    private(set) var filteredCurrencies = [RandomlyGeneratedCurrency]()
    private(set) var chosenCurrencies = [RandomlyGeneratedCurrency]() {
        didSet {
            synchronizeCurrencies()
        }
    }
    
    weak var delegate: CurrencyDelegatePrtocol?
    
    init(aomuntOfCurrencies: Int, amountOfChosenCurrencies: Int) {
        super.init()
        let currencyNames = RandomlyGeneratedCurrency.generateRandomNames(quantityOfNames: aomuntOfCurrencies)
        for name in currencyNames {
            allCurrencies.append(
                RandomlyGeneratedCurrency(
                    id: UUID(),
                    name: name,
                    value: Double.random(in: 10...1000),
                    type: CurrencyType.allCases.randomElement() ?? .crypto,
                    isChosen: false
                )
            )
        }
        for _ in .zero..<amountOfChosenCurrencies {
            chosenCurrencies.append(RandomlyGeneratedCurrency.generatePlaceholderCurrency())
        }
    }
    
    func generateNewValues() {
        for index in allCurrencies.indices {
            let currency = RandomlyGeneratedCurrency(
                id:  allCurrencies[index].id,
                name: allCurrencies[index].name,
                value: .random(in: 10...1000),
                type: allCurrencies[index].type,
                isChosen: allCurrencies[index].isChosen
            )
            allCurrencies[index] = currency
            if currency.isChosen {
                if let chosenCurrencyIndex = chosenCurrencies.firstIndex(where: { $0.id == currency.id }) {
                    chosenCurrencies[chosenCurrencyIndex] = currency
                }
            }
        }
        if let currencyTypeFilteredBy {
            filterCurrenciesByType(currencyTypeFilteredBy)
        }
    }
    
    func chooseCurrency(currency: RandomlyGeneratedCurrency, chosenCurrenciesIndex: Int) {
        if allCurrencies.firstIndex(where: { !$0.isChosen && $0.id == currency.id }) != nil {
            let chosenCurrency = RandomlyGeneratedCurrency(
                id: currency.id,
                name: currency.name,
                value: currency.value,
                type: currency.type,
                isChosen: true
            )
            addCurencyToChosen(currency: chosenCurrency, atIndex: chosenCurrenciesIndex)
        }
    }
    
    func clearFilters() {
        currencyTypeFilteredBy = nil
        filteredCurrencies.removeAll()
    }
    
    func filterCurrenciesByType(_ currencyType: CurrencyType) {
        currencyTypeFilteredBy = currencyType
        filteredCurrencies = allCurrencies.filter { $0.type == currencyType }
    }
    
    func convertCurrency(atChosenCurrencyIndex fromIndex: Int, toChosenCurrencyIndex toIndex: Int) -> Double {
        return chosenCurrencies[toIndex].value == 0 ? 0 : chosenCurrencies[fromIndex].value / chosenCurrencies[toIndex].value
    }
}

// MARK: - Private Methods
private extension CurrencyDataProvider {
    func addCurencyToChosen(currency: RandomlyGeneratedCurrency, atIndex index: Int) {
        chosenCurrencies[index] = currency
    }
    
    func synchronizeCurrencies() {
        let chosenCurrenciesIndetifiers = getChosenCurrenciesIdentifiers()
        for index in allCurrencies.indices {
            if chosenCurrenciesIndetifiers.contains(allCurrencies[index].id) {
                allCurrencies[index] = RandomlyGeneratedCurrency(
                    id: allCurrencies[index].id,
                    name: allCurrencies[index].name,
                    value: allCurrencies[index].value,
                    type: allCurrencies[index].type,
                    isChosen: true
                )
            } else {
                allCurrencies[index] = RandomlyGeneratedCurrency(
                    id: allCurrencies[index].id,
                    name: allCurrencies[index].name,
                    value: allCurrencies[index].value,
                    type: allCurrencies[index].type,
                    isChosen: false
                )
            }
        }
        if let currencyTypeFilteredBy {
            filterCurrenciesByType(currencyTypeFilteredBy)
        }
    }
    
    func getChosenCurrenciesIdentifiers() -> [UUID] {
        var identifiers = [UUID]()
        for currency in self.chosenCurrencies {
            identifiers.append(currency.id)
        }
        return identifiers
    }
}

extension CurrencyDataProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencyTypeFilteredBy != nil ? filteredCurrencies.count : allCurrencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.identifier, for: indexPath) as? CurrencyCell
        cell?.displayedCurrency = currencyTypeFilteredBy != nil ? filteredCurrencies[indexPath.row] : allCurrencies[indexPath.row]
        return cell ?? UICollectionViewCell()
    }
}

extension CurrencyDataProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = currencyTypeFilteredBy != nil ? filteredCurrencies[indexPath.row] : allCurrencies[indexPath.row]
        delegate?.currencyChosen(currency)
    }
}
