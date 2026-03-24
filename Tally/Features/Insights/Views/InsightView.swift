//
//  InsightView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/24/26.
//


import SwiftUI

struct InsightsView: View {
    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.primaryBlue.opacity(0.4))
                Text("Insights")
                    .font(.urbanist(.bold, size: 24))
                    .foregroundStyle(Color.heading)
                Text("Coming soon")
                    .font(.manrope(.medium, size: 14))
                    .foregroundStyle(Color.mutedText)
            }
        }
    }
}
