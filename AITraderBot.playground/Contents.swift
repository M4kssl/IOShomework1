import UIKit

let allCurrencies = ["euro", "dollar", "yen"]

var boughtCurrencies = [String:(quantity: Double, value: Double)]()
var initialMarketValues = [String:Double]()
var balance: Double = 1000

for currency in allCurrencies {
    let value = Double.random(in: 1...100)
    initialMarketValues[currency] = value
    print("initial market value of \(currency) is \(value)")
}


for _ in 0...10{
    for currency in allCurrencies {
        let marketValue = Double.random(in: 1...100)
        if let initialMarketValue = initialMarketValues[currency]{
            if let boughtCurrency = boughtCurrencies[currency], boughtCurrency.value < marketValue {
                balance += boughtCurrency.value * boughtCurrency.quantity
                initialMarketValues[currency] = marketValue 
                print("\(currency) \(marketValue) - to sell")
                print("to sell FROM \(boughtCurrency.quantity*boughtCurrency.value) -> TO \(boughtCurrency.quantity * marketValue)")
            }else if initialMarketValue > marketValue, marketValue <= balance{
                let quantityToBuy = quantityToBuy(with: balance, for: marketValue)
                balance -= quantityToBuy * marketValue
                print("\(currency) \(marketValue) - to buy")
                print("to buy FROM \(quantityToBuy * initialMarketValue) -> TO \(quantityToBuy * marketValue)")
            }else{
                print("\(currency) \(marketValue) - ignore")
            }
        }
    }
}

func quantityToBuy(with balance: Double, for marketValue: Double) -> Double{
    let maximumQuantity = balance/marketValue
    return Double.random(in: 1...maximumQuantity)
}
