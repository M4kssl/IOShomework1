//
//  CurrencyDataGenerator.swift
//  homework4
//
//  Created by Максим  on 29.03.2026.
//

import Foundation
import UIKit

protocol CurrencyDelegatePrtocol: AnyObject {
    func currencyChosen(from currencies: [RandomlyGeneratedCurrency], at indexPath: IndexPath)
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
    func switchFilterByNetwork(isFilterOn: Bool)
}

final class CurrencyDataProvider: NSObject, CurrencyDataProviderProtocol {
    private var currencyTypeFilteredBy: CurrencyType?
    private var isFilteredByFavorite: Bool = false
    private var isFilteredByNet: Bool = false
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
                    isFavorited: false,
                    isFromNet: false
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
            let currency = RandomlyGeneratedCurrency.changeQuanityForCurrency(currency: allCurrencies[index], newQuantity: .random(in: 10...100)
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
                isFavorited: currency.isFavorited,
                isFromNet: currency.isFavorited
            )
            addCurencyToChosen(currency: chosenCurrency, atIndex: chosenCurrenciesIndex)
        }
    }
    
    func clearFilterByType() {
        currencyTypeFilteredBy = nil
        
        var filteredCurrencies = [RandomlyGeneratedCurrency]()
        
        if isFilteredByFavorite {
            filteredCurrencies = filteredCurrencies.filter { $0.isFavorited }
        }
        
        if isFilteredByNet {
            filteredCurrencies = filteredCurrencies.filter { $0.isFromNet }
        }
        
        self.filteredCurrencies = filteredCurrencies
    }
    
    func filterCurrenciesByType(_ currencyType: CurrencyType) {
        currencyTypeFilteredBy = currencyType
        filteredCurrencies = allCurrencies.filter { $0.type == currencyType }
        
        if isFilteredByFavorite {
            filteredCurrencies = filteredCurrencies.filter { $0.isFavorited }
        }
        if isFilteredByNet {
            filteredCurrencies = filteredCurrencies.filter { $0.isFromNet }
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
    
    func switchFilterByNetwork(isFilterOn: Bool) {
        isFilteredByNet = isFilterOn
        if isFilterOn {
            turnNetFilterOn()
        } else {
            turnNetFilterOff()
        }
    }
}

// MARK: - Private Methods
private extension CurrencyDataProvider {
    func addCurencyToChosen(currency: RandomlyGeneratedCurrency, atIndex index: Int) {
        chosenCurrencies[index] = currency
    }
    
    func turnFavoriteFilterOn() {
        if currencyTypeFilteredBy != nil || isFilteredByNet {
            filteredCurrencies = filteredCurrencies.filter { $0.isFavorited }
        } else {
            filteredCurrencies = allCurrencies.filter { $0.isFavorited }
        }
    }
    
    func turnNetFilterOn() {
        if currencyTypeFilteredBy != nil || isFilteredByFavorite {
            filteredCurrencies = filteredCurrencies.filter { $0.isFromNet }
        } else {
            filteredCurrencies = allCurrencies.filter { $0.isFromNet }
        }
    }
    
    func turnFavoriteFilterOff() {
        if let currencyTypeFilteredBy {
            filterCurrenciesByType(currencyTypeFilteredBy)
        } else {
            clearFilterByType()
        }
    }
    
    func turnNetFilterOff() {
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
                isFromNet: allCurrencies[index].isFromNet
            )
        }
        
        var updatedCurrencies = allCurrencies
        
        if isFilteredByFavorite {
            updatedCurrencies = updatedCurrencies.filter { $0.isFavorited }
        }
        
        if isFilteredByNet {
            updatedCurrencies = updatedCurrencies.filter { $0.isFromNet }
        }
        
        filteredCurrencies = updatedCurrencies
        
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
                isFavorited: !allCurrencies[index].isFavorited,
                isFromNet: allCurrencies[index].isFromNet
            )
        }
    }
}

extension CurrencyDataProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int
        if isFilteredByFavorite || currencyTypeFilteredBy != nil || isFilteredByNet {
            count = filteredCurrencies.count
        } else {
            count = allCurrencies.count
        }
        return count == .zero ? 1 : count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var arrayToDisplay = [RandomlyGeneratedCurrency]()
        if isFilteredByFavorite || currencyTypeFilteredBy != nil || isFilteredByNet {
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
        if isFilteredByFavorite || currencyTypeFilteredBy != nil || isFilteredByNet {
            arrayToDisplay = filteredCurrencies
        } else {
            arrayToDisplay = allCurrencies
        }
        if !arrayToDisplay.isEmpty {
            delegate?.currencyChosen(from: arrayToDisplay, at: indexPath)
        }
    }
}

extension CurrencyDataProvider: CurrencyCellDelegate {
    func favoiteMarkChanged(for currency: RandomlyGeneratedCurrency) {
        changeFavoriteMark(currency: currency)
        delegate?.favoriteMarkChanged()
    }
}
