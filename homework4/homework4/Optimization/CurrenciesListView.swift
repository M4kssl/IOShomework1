import Foundation
import SwiftUI
import UIKit
import Combine

struct OptimizationCurrencyPair: Identifiable, Equatable {
    let id: UUID
    let name: String
    var value: Double
    var previousValue: Double
    var history: [Double]
    
    var changePercent: Double {
        guard previousValue != 0 else { return 0 }
        return (value - previousValue) / previousValue * 100
    }
}

@MainActor
final class CurrencyPairsGenerator: ObservableObject {
    static let pairsCount = 500
    
    @Published private(set) var pairs: [OptimizationCurrencyPair] = []
    @Published private(set) var lastUpdatedPairs: [OptimizationCurrencyPair] = []
    @Published private(set) var updateCycle: Int = 0
    
    private var timer: Timer?
    
    init() {
        pairs = Self.makePairs()
        lastUpdatedPairs = Array(pairs.prefix(12))
        startUpdating()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateRandomPairs()
            }
        }
    }
    
    private func updateRandomPairs() {
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

    private static func makePairs() -> [OptimizationCurrencyPair] {
        (0..<pairsCount).map { _ in
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

    private static func randomCode() -> String {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return String((0..<3).map { _ in letters.randomElement()! })
    }
}

struct RecentUpdatedPairsView: View {
    let id: Int = 0
    let lastUpdatedPairs: [OptimizationCurrencyPair]
    let updateCycle: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Последние обновления")
                .font(.headline)
                .padding(.horizontal, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(lastUpdatedPairs) { pair in
                        RecentCurrencyPairCard(
                            pair: pair,
                            updateCycle: updateCycle
                        )
                        .equatable()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .padding(.top, 12)
        .background(Color.black.opacity(0.04))
    }
}

struct BadCurrencyPairsView: View {
    @StateObject private var generator = CurrencyPairsGenerator()
    @State private var highlightRisk: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Подсвечивать рискованные пары", isOn: $highlightRisk)
                .padding()
                .background(Color.gray.opacity(0.12))
            
            RecentUpdatedPairsView(lastUpdatedPairs: generator.lastUpdatedPairs, updateCycle: generator.updateCycle)
                .equatable()
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(generator.pairs) { pair in
                        CurrenciesListElementView(pair: pair, highlightRisk: $highlightRisk)
                    }
                }
                .padding(.vertical, 12)
            }
        }
    }
}

struct RecentCurrencyPairCard: View, Equatable {
    let pair: OptimizationCurrencyPair
    let updateCycle: Int

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.pair.id == rhs.pair.id &&
        lhs.updateCycle == rhs.updateCycle
    }

    var body: some View {
        let prepared = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 4
            formatter.maximumFractionDigits = 5

            let price = formatter.string(
                from: NSNumber(value: pair.value)
            ) ?? "\(pair.value)"

            var checksum = 0

            for scalar in pair.name.unicodeScalars {
                checksum += Int(scalar.value)
            }

            for index in 0..<20_000 {
                checksum = (checksum * 31 + index + Int(pair.value * 1000)) % 1_000_003
            }

            return (
                price: price,
                checksum: checksum,
                isGrowing: pair.value >= pair.previousValue
            )
        }()

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pair.name)
                    .font(.caption.bold())

                Spacer()

                Circle()
                    .fill(prepared.isGrowing ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
            }

            Text(prepared.price)
                .font(.system(size: 17, weight: .semibold, design: .monospaced))

            Text("\(pair.changePercent, specifier: "%.2f")%")
                .font(.caption)
                .foregroundColor(prepared.isGrowing ? .green : .red)

            Text("cycle \(updateCycle) / \(prepared.checksum)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 150, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 8)
    }
}

extension RecentUpdatedPairsView: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.updateCycle == rhs.updateCycle &&
        lhs.id == rhs.id
    }
}

struct CurrenciesListElementView: View {
    var pair: OptimizationCurrencyPair
    @Binding var highlightRisk: Bool
    
    var body: some View {
        let prepared = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 4
            formatter.maximumFractionDigits = 6

            let priceText = formatter.string(
                from: NSNumber(value: pair.value)
            ) ?? "\(pair.value)"

            let attributedText = NSMutableAttributedString(
                string: priceText,
                attributes: [
                    .font: UIFont.monospacedDigitSystemFont(
                        ofSize: 18,
                        weight: .semibold
                    ),
                    .foregroundColor: pair.value >= pair.previousValue
                        ? UIColor.systemGreen
                        : UIColor.systemRed
                ]
            )

            let history = pair.history
            var returns: [Double] = []

            if history.count > 1 {
                for index in 1..<history.count {
                    let previous = max(history[index - 1], 0.0001)
                    returns.append(log(history[index] / previous))
                }
            }

            let averageReturn = returns.reduce(0, +) / Double(max(returns.count, 1))

            let variance = returns.reduce(0) {
                $0 + pow($1 - averageReturn, 2)
            } / Double(max(returns.count, 1))

            let volatility = sqrt(variance) * sqrt(252)

            var gains = 0.0
            var losses = 0.0
            let startIndex = max(1, history.count - 14)

            if history.count > 1 {
                for index in startIndex..<history.count {
                    let diff = history[index] - history[index - 1]

                    if diff >= 0 {
                        gains += diff
                    } else {
                        losses += abs(diff)
                    }
                }
            }

            let rsi: Double
            if losses == 0 {
                rsi = 100
            } else {
                let rs = gains / losses
                rsi = 100 - 100 / (1 + rs)
            }

            var simulatedLosses: [Double] = []

            for path in 0..<900 {
                var simulatedPrice = pair.value

                for step in 0..<30 {
                    let noise = sin(Double(path * 31 + step * 17))
                        * cos(Double(step + abs(pair.name.hashValue % 1000)))

                    simulatedPrice *= exp(averageReturn + volatility * 0.02 * noise)
                }

                simulatedLosses.append(pair.value - simulatedPrice)
            }

            let sortedLosses = simulatedLosses.sorted()
            let valueAtRisk = sortedLosses[
                min(sortedLosses.count - 1, Int(Double(sortedLosses.count) * 0.95))
            ]

            return (
                price: AttributedString(attributedText),
                volatility: volatility,
                rsi: rsi,
                valueAtRisk: valueAtRisk
            )
        }()

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(pair.name)
                    .font(.headline)

                Text(prepared.price)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("RSI \(prepared.rsi, specifier: "%.2f")")
                Text("Vol \(prepared.volatility, specifier: "%.4f")")
                Text("VaR \(prepared.valueAtRisk, specifier: "%.4f")")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    highlightRisk && prepared.volatility > 0.12
                        ? Color.yellow.opacity(0.45)
                        : Color.gray.opacity(0.12)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 8)
        .padding(.horizontal, 12)
        .animation(.easeInOut(duration: 0.2), value: pair.value)
    }
}
