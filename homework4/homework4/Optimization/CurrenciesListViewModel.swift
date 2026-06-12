//
//  CurrenciesListViewModel.swift
//  homework4
//
//  Created by Максим  on 11.06.2026.
//

import Foundation

struct CurrenciesListsData {
    let allPairs: [OptimizationCurrencyPair]
    let lastUpdatedPairs: [OptimizationCurrencyPair]
    let updateCycle: Int
}

enum CurrencyListState {
    case empty
    case loading
    case loaded((CurrenciesListsData))
    case error
}

enum CurrencyListAction {
    case appear
    case load
    case update
}

@MainActor
final class CurrencyPairsGenerator: ObservableObject {
    @Published var state = CurrencyListState.empty
    
    private static let pairsCount: Int = 500
    
    private(set) var updateCycle: Int = .zero
    private var pairs: [OptimizationCurrencyPair] = []
    private var lastUpdatedPairs: [OptimizationCurrencyPair] = []
    private var timer: Timer?
    
    init() {
        startUpdating()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func dispatch(action: CurrencyListAction) {
        switch action{
        case .appear:
            reduce(action: action)
            pairs = Self.makePairs()
            if !pairs.isEmpty {
                lastUpdatedPairs = Array(pairs.prefix(12))
            }
        case .load:
            reduce(action: action)
        case .update:
            updateRandomPairs()
            reduce(action: action)
        }
    }
}

// MARK: - Private Methods
private extension CurrencyPairsGenerator {
    func reduce(action: CurrencyListAction) {
        switch action {
        case .appear:
            state = .loading
        case .load, .update:
            state = pairs.isEmpty ? .error : .loaded(CurrenciesListsData(
                allPairs: pairs,
                lastUpdatedPairs: lastUpdatedPairs,
                updateCycle: updateCycle
            ))
        }
    }
    
    func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.dispatch(action: .update)
            }
        }
    }
    
    func updateRandomPairs() {
        guard !pairs.isEmpty else { return }
        
        var updatedPairs = pairs
        let updateCount = Int.random(in: 8...35)
        var indexes = Set<Int>()
        
        while indexes.count < updateCount {
            indexes.insert(Int.random(in: updatedPairs.indices))
        }
        
        for index in indexes {
            updatedPairs[index].previousValue = updatedPairs[index].value
            updatedPairs[index].value = max(
                0.0001,
                updatedPairs[index].value * Double.random(in: 0.985...1.015)
            )
            
            updatedPairs[index].history.append(updatedPairs[index].value)
            
            if updatedPairs[index].history.count > 240 {
                updatedPairs[index].history.removeFirst(
                    updatedPairs[index].history.count - 240
                )
            }
        }
        
        pairs = updatedPairs
        lastUpdatedPairs = indexes
            .sorted()
            .map { updatedPairs[$0] }
        
        updateCycle += 1
    }
}

// MARK: - Private Static Methods
private extension CurrencyPairsGenerator {
    static func makePairs() -> [OptimizationCurrencyPair] {
        let shouldBeEmpty = Bool.random()
        guard !shouldBeEmpty else { return [] }
        
        return (0..<pairsCount).map { _ in
            var value = Double.random(in: 0.5...180)
            var history: [Double] = []

            for _ in 0..<120 {
                value = max(0.0001, value * Double.random(in: 0.995...1.005))
                history.append(value)
            }

            return OptimizationCurrencyPair(
                id: UUID(),
                name: "\(randomCode())/\(randomCode())",
                value: value,
                previousValue: history.dropLast().last ?? value,
                history: history
            )
        }
    }

    static func randomCode() -> String {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return String((0..<3).map { _ in letters.randomElement()! })
    }
}
