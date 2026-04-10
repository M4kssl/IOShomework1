//
//  CurrencyDataGenerator.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//

import Foundation
import UIKit

protocol CurrencyDelegatePrtocol: AnyObject {
    func currencyChosen(_ currency: RandomlyGeneratedCurrency)
    func favoriteMarkChanged()
}

protocol CurrencyDataProviderProtocol {
    var allCurrencies: [RandomlyGeneratedCurrency] { get }
    var chosenCurrencies: [RandomlyGeneratedCurrency] { get }
    var filteredCurrencies: [RandomlyGeneratedCurrency] { get }
    var delegate: CurrencyDelegatePrtocol? { get set }
    func generateNewValues()
    func chooseCurrency(currency: RandomlyGeneratedCurrency, chosenCurrenciesIndex: Int)
    func filterCurrenciesByType(_ currencyType: CurrencyType)
    func clearFilterByType()
    func convertCurrency(atChosenCurrencyIndex fromIndex: Int, toChosenCurrencyIndex toIndex: Int) -> Double
    func switchFilterByFavorite(isFilterOn: Bool)
}

final class CurrencyDataProvider: NSObject, CurrencyDataProviderProtocol {
    private var currencyTypeFilteredBy: CurrencyType?
    private var isFilteredByFavorite: Bool = false
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
                    value: Double.random(in: 10...100),
                    quantity: 1,
                    type: CurrencyType.allCases.randomElement() ?? .crypto,
                    isChosen: false,
                    isFavorited: false
                )
            )
        }
        for _ in .zero..<amountOfChosenCurrencies {
            chosenCurrencies.append(RandomlyGeneratedCurrency.generatePlaceholderCurrency())
        }
    }
    
    init(currencies: [RandomlyGeneratedCurrency], chosenCurrencies: [RandomlyGeneratedCurrency]) {
        for currency in currencies {
            allCurrencies.append(currency)
        }
        
        for currency in chosenCurrencies {
            self.chosenCurrencies.append(currency)
        }
    }
    
    func generateNewValues() {
        for index in allCurrencies.indices {
            let currency = RandomlyGeneratedCurrency(
                id:  allCurrencies[index].id,
                name: allCurrencies[index].name,
                value: .random(in: 10...100),
                quantity: allCurrencies[index].quantity,
                type: allCurrencies[index].type,
                isChosen: allCurrencies[index].isChosen,
                isFavorited: allCurrencies[index].isFavorited
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
        if isFilteredByFavorite {
            turnFavoriteFilterOn()
        }
    }
    
    func chooseCurrency(currency: RandomlyGeneratedCurrency, chosenCurrenciesIndex: Int) {
        if allCurrencies.firstIndex(where: { !$0.isChosen && $0.id == currency.id }) != nil {
            let chosenCurrency = RandomlyGeneratedCurrency(
                id: currency.id,
                name: currency.name,
                value: currency.value,
                quantity: currency.quantity,
                type: currency.type,
                isChosen: true,
                isFavorited: currency.isFavorited
            )
            addCurencyToChosen(currency: chosenCurrency, atIndex: chosenCurrenciesIndex)
        }
    }
    
    func clearFilterByType() {
        currencyTypeFilteredBy = nil
        if isFilteredByFavorite {
            filteredCurrencies = allCurrencies.filter { $0.isFavorited }
        } else {
            filteredCurrencies.removeAll()
        }
    }
    
    func filterCurrenciesByType(_ currencyType: CurrencyType) {
        currencyTypeFilteredBy = currencyType
        filteredCurrencies = allCurrencies.filter { $0.type == currencyType }
        if isFilteredByFavorite {
            filteredCurrencies = filteredCurrencies.filter { $0.isFavorited }
        }
    }
    
    func convertCurrency(atChosenCurrencyIndex fromIndex: Int, toChosenCurrencyIndex toIndex: Int) -> Double {
        return chosenCurrencies[toIndex].value == .zero ? .zero : chosenCurrencies[fromIndex].value / chosenCurrencies[toIndex].value
    }
    
    func switchFilterByFavorite(isFilterOn: Bool) {
        isFilteredByFavorite = isFilterOn
        if isFilterOn {
            turnFavoriteFilterOn()
        } else {
            turnFavoriteFilterOff()
        }
    }
}

// MARK: - Private Methods
private extension CurrencyDataProvider {
    func addCurencyToChosen(currency: RandomlyGeneratedCurrency, atIndex index: Int) {
        chosenCurrencies[index] = currency
    }
    
    func turnFavoriteFilterOn() {
        if currencyTypeFilteredBy != nil {
            filteredCurrencies = filteredCurrencies.filter { $0.isFavorited }
        } else {
            filteredCurrencies = allCurrencies.filter { $0.isFavorited }
        }
    }
    
    func turnFavoriteFilterOff() {
        if let currencyTypeFilteredBy {
            filterCurrenciesByType(currencyTypeFilteredBy)
        } else {
            clearFilterByType()
        }
    }
    
    func synchronizeCurrencies() {
        let chosenCurrenciesIndetifiers = getChosenCurrenciesIdentifiers()
        for index in allCurrencies.indices {
            let isChosen = chosenCurrenciesIndetifiers.contains(allCurrencies[index].id)
            allCurrencies[index] = RandomlyGeneratedCurrency(
                id: allCurrencies[index].id,
                name: allCurrencies[index].name,
                value: allCurrencies[index].value,
                quantity: allCurrencies[index].quantity,
                type: allCurrencies[index].type,
                isChosen: isChosen,
                isFavorited: allCurrencies[index].isFavorited,
                
            )
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
    
    func changeFavoriteMark(currency: RandomlyGeneratedCurrency) {
        if let index = allCurrencies.firstIndex(where: { $0.id == currency.id }) {
            allCurrencies[index] = RandomlyGeneratedCurrency(
                id: allCurrencies[index].id,
                name: allCurrencies[index].name,
                value: allCurrencies[index].value,
                quantity: allCurrencies[index].quantity,
                type: allCurrencies[index].type,
                isChosen: allCurrencies[index].isChosen,
                isFavorited: !allCurrencies[index].isFavorited)
        }
    }
}

extension CurrencyDataProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int
        if isFilteredByFavorite || currencyTypeFilteredBy != nil {
            count = filteredCurrencies.count
        } else {
            count = allCurrencies.count
        }
        return count == .zero ? 1 : count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var arrayToDisplay = [RandomlyGeneratedCurrency]()
        if isFilteredByFavorite || currencyTypeFilteredBy != nil {
            arrayToDisplay = filteredCurrencies
        } else {
            arrayToDisplay = allCurrencies
        }
        if arrayToDisplay.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyCell.identifier,
                for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.identifier,for: indexPath) as? CurrencyCell
            cell?.delegate = self
            cell?.displayedCurrency = arrayToDisplay[indexPath.row]
            return cell ?? UICollectionViewCell()
        }
    }
}

extension CurrencyDataProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var arrayToDisplay = [RandomlyGeneratedCurrency]()
        if isFilteredByFavorite || currencyTypeFilteredBy != nil {
            arrayToDisplay = filteredCurrencies
        } else {
            arrayToDisplay = allCurrencies
        }
        if !arrayToDisplay.isEmpty {
            delegate?.currencyChosen(arrayToDisplay[indexPath.row])
        }
    }
}

extension CurrencyDataProvider: CurrencyCellDelegate {
    func favoiteMarkChanged(for currency: RandomlyGeneratedCurrency) {
        changeFavoriteMark(currency: currency)
        delegate?.favoriteMarkChanged()
    }
}
