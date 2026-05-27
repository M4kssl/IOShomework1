//
//  Heatmap.swift
//  homework4
//
//  Created by Максим  on 24.05.2026.
//

import SwiftUI

struct Heatmap: View {
    var body: some View {
        ZStack {
            Color(.systemYellow)
                .ignoresSafeArea()
            VStack {
                Text("Heatmap")
                    .font(.largeTitle)
                Spacer()
                HeatmapCell(backgroundColor: Colors.rising, currencyName: "BTC", percent: "+ 3.01%")
                HStack {
                    VStack {
                        HeatmapCell(backgroundColor: Colors.falling, currencyName: "ETH", percent: "- 4.28%")
                        HeatmapCell(backgroundColor: Colors.slowRising, currencyName: "USDT", percent: "+ 0.04%")
                    }
                    VStack {
                        HeatmapCell(backgroundColor: Colors.slowFalling, currencyName: "XRP", percent: "- 2.24%")
                        HStack {
                            VStack {
                                HeatmapCell(backgroundColor: Colors.noChange, currencyName: "USDC", percent: "0.0%")
                                HeatmapCell(backgroundColor: Colors.falling, currencyName: "SOL", percent: "- 4.79%")
                            }
                            VStack {
                                HeatmapCell(backgroundColor: Colors.slowFalling, currencyName: "TRX", percent: "- 0.84%")
                                HStack {
                                    VStack {
                                        HeatmapCell(backgroundColor: Colors.falling, currencyName: "DOGE", percent: "- 10.04%")
                                        HeatmapCell(backgroundColor: Colors.falling, currencyName: "HYPE", percent: "- 7.22%")
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
}

private extension Heatmap {
    enum Colors {
        static let rising = Color(red: 51/255, green: 255/255, blue: 51/255, opacity: 1)
        static let slowRising = Color(red: 133/255, green: 255/255, blue: 133/255, opacity: 1)
        static let falling = Color(red: 1, green: 51/255, blue: 51/255, opacity: 1)
        static let slowFalling = Color(red: 1, green: 133/255, blue: 133/255, opacity: 1)
        static let noChange = Color(red:200/255, green: 200/255, blue: 200/255, opacity: 1)
    }
}
