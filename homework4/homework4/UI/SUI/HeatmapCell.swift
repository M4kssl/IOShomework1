//
//  HeatmapCell.swift
//  HeatmapSUI
//
//  Created by Максим  on 23.05.2026.
//

import SwiftUI

struct HeatmapCell: View {
    let backgroundColor: Color
    let currencyName: String
    let percent: String
    
    var body: some View {
        VStack {
            Text(currencyName)
                .font(.largeTitle)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            Text(percent)
                .font(.largeTitle)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
}
