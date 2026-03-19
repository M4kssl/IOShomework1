import UIKit

enum Actions {
    case ignore
    case purchase
    case sell
}

struct Currency {
    let name: CurrencyNames
    var quantity: Double
    var value: Double
    
    enum CurrencyNames: String, CaseIterable {
        case usd
        case eur
        case gbp
        case jpy
    }
}

struct Deal {
    let action: Actions
    let currency: Currency
    let timestamp: Date
}

struct RequestForMarket {
    let action: Actions
    let currency: Currency
    let quantity: Double
}

struct MarketResponse {
    let request: RequestForMarket
    let status: MarketResponseStatuses
    let messege: String?
    
    enum MarketResponseStatuses: String {
        case success
        case failure
    }
}

protocol BotProtocol {
    var balance: Double { get }
    var currenciesOnHand: [Currency] { get }
    func decideOnAction(for currency: Currency) -> Actions
    func formARequestForMarket(toMake action: Actions, for currency: Currency) -> RequestForMarket
    func processMarketResponse(_ response: MarketResponse)
}

protocol MarketProtocol {
    var currencies: [Currency] { get }
    func updateCurrenciesValues()
    func processRequestAndFormAResponse(_ request: RequestForMarket) -> MarketResponse
    
}

protocol LoggerProtocol {
    func logAction(_ action: Actions, for currency: Currency)
    func logLastDealResult(_ dealHistory: [Deal])
    func logMarketResponse(_ response: MarketResponse)
}

final class Logger: LoggerProtocol {
    func logAction(_ action: Actions, for currency: Currency) {
        print("\(currency.name) \(currency.value) - to \(action)")
    }
    func logLastDealResult(_ dealHistory: [Deal]) {
        
        if let lastDeal = dealHistory.last {
            switch lastDeal.action {
                case .purchase:
                if let deal = dealHistory.last(where: { $0.action == .sell && $0.currency.name == lastDeal.currency.name }) {
                    print("\(lastDeal.action) FROM = \(lastDeal.currency.quantity * deal.currency.value) -> TO = \(lastDeal.currency.quantity * lastDeal.currency.value), INCOME = \(lastDeal.currency.quantity * lastDeal.currency.value - lastDeal.currency.quantity * deal.currency.value)")
                    } else {
                        print("\(lastDeal.action) FROM = 0 -> TO = \(lastDeal.currency.quantity * lastDeal.currency.value), INCOME = \(lastDeal.currency.quantity * lastDeal.currency.value)")
                    }
                case .sell:
                if let deal = dealHistory.last(where: { $0.action == .purchase && $0.currency.name == lastDeal.currency.name }) {
                    print("\(lastDeal.action) FROM = \(lastDeal.currency.quantity * deal.currency.value) -> TO = \(lastDeal.currency.quantity * lastDeal.currency.value), INCOME = \(lastDeal.currency.quantity * lastDeal.currency.value - lastDeal.currency.quantity * deal.currency.value)")
                    }
                case .ignore:
                    break
            }
        }
    }
    func logMarketResponse(_ response: MarketResponse) {
        switch response.status {
        case .success:
            print("Request approved")
        case .failure:
            print("Request declined, reason: \(response.messege ?? "No reason provided")")
        }
    }
}

final class Bot: BotProtocol {
    
    var dealHistory: [Deal] = []
    var balance: Double
    var currenciesOnHand: [Currency] = []
    private let maxValueToPurchase: Double = 65
    private let logger: LoggerProtocol
    
    init (logger: LoggerProtocol) {
        balance = 1000
        for currency in Currency.CurrencyNames.allCases {
            currenciesOnHand.append(Currency(name: currency, quantity: 0, value: 0))
        }
        self.logger = logger
    }
    
    func decideOnAction(for currency: Currency) -> Actions {
        var decidedAction = Actions.ignore
        if let currencyOnHand = currenciesOnHand.first(where: { $0.name == currency.name }) {
            if currencyOnHand.quantity > 0, currencyOnHand.value < currency.value {
                decidedAction = .sell
            } else if currencyOnHand.quantity == 0, currency.value <= balance, currency.value < maxValueToPurchase {
                decidedAction = .purchase
            }
        }
        logger.logAction(decidedAction, for: currency)
        return decidedAction
    }
    
    func formARequestForMarket(toMake action: Actions, for currency:  Currency) -> RequestForMarket {
        switch action {
        case .purchase:
            let quantity = Bot.quantityToBuy(for: currency, balance)
            return RequestForMarket(action: action, currency: currency, quantity: quantity)
        case .sell:
            if let currencyOnHand = currenciesOnHand.first(where: { $0.name == currency.name }) {
                return RequestForMarket(action: action, currency: currency, quantity: currencyOnHand.quantity)
            } else {
                return RequestForMarket(action: .ignore, currency: currency, quantity: 0)
            }
        default:
            return RequestForMarket(action: .ignore, currency: currency, quantity: 0)
        }
    }
    
    func processMarketResponse(_ response: MarketResponse) {
        guard response.status == .success else {
            logger.logMarketResponse(response)
            return
        }
        if let currencyOnHandIndex = currenciesOnHand.firstIndex(where: { $0.name == response.request.currency.name }) {
            switch response.request.action{
            case .purchase:
                currenciesOnHand[currencyOnHandIndex].quantity += response.request.quantity
                currenciesOnHand[currencyOnHandIndex].value = response.request.currency.value
                balance -= response.request.quantity * response.request.currency.value
            case .sell:
                currenciesOnHand[currencyOnHandIndex].quantity -= response.request.quantity
                currenciesOnHand[currencyOnHandIndex].value = 0
                balance += response.request.quantity * response.request.currency.value
            default:
                break
            }
            registerDeal(for: response.request.currency, action: response.request.action)
            logger.logLastDealResult(dealHistory)
        }
    }
    
    func registerDeal(for currency: Currency, action: Actions) {
        dealHistory.append(Deal(action: action, currency: currency, timestamp: Date()))
    }
        
    private static func quantityToBuy(for currency: Currency, _ balance: Double) -> Double {
        let maximumQuantity = balance/currency.value
        return Double.random(in: 1...maximumQuantity)
    }
}

final class Market: MarketProtocol {
    
    private(set) var currencies: [Currency] = []
    
    init () {
        for currency in Currency.CurrencyNames.allCases {
            currencies.append(Currency(name: currency, quantity: 80, value: Double.random(in: 1...100)))
        }
    }
    
    func updateCurrenciesValues() {
        for i in currencies.indices {
            currencies[i].value = Double.random(in: 1...100)
        }
    }
    
    func processRequestAndFormAResponse(_ request: RequestForMarket) -> MarketResponse {
        switch request.action {
        case .ignore:
            return MarketResponse(request: request, status: .success, messege: nil)
        case .purchase:
            if let index = currencies.firstIndex(where: { $0.name == request.currency.name }) {
                if currencies[index].quantity < request.quantity {
                    return MarketResponse(request: request, status: .failure, messege: "Not enough quantity avalible. Request for \(request.quantity), avalible \(currencies[index].quantity)")
                }
                currencies[index].quantity -= request.quantity
                return MarketResponse(request: request, status: .success, messege: nil)
            }
        case .sell:
            if let index = currencies.firstIndex(where: { $0.name == request.currency.name }) {
                currencies[index].quantity += request.quantity
                return MarketResponse(request: request, status: .success, messege: nil)
            }
        }
        return MarketResponse(request: request, status: .failure, messege: "Something went wrong")
    }
    
    func setCurrencyValue(for currency: Currency, to value: Double) {
        if let index = currencies.firstIndex(where: { $0.name == currency.name }) {
            currencies[index].value = value;
        }
    }
}

var currencyMarket = Market()
let logger = Logger()
var bot = Bot(logger: logger)

for _ in 0...5 {
    currencyMarket.updateCurrenciesValues()
    for currency in currencyMarket.currencies{
        let action = bot.decideOnAction(for: currency)
        let request = bot.formARequestForMarket(toMake: action, for: currency)
        let response = currencyMarket.processRequestAndFormAResponse(request)
        bot.processMarketResponse(response)
        
    }
    
}

