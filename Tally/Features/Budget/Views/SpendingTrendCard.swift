//
//  SpendingTrendCard.swift
//  Tally
//
//  Created by Mazen Tarek on 4/9/26.
//

import Charts
import SwiftUI

// Struct that holds the weekly spending data.
struct WeeklySpending: Identifiable {
    let id = UUID()
    let week: String
    let amount: Double
}

struct SpendingTrendCard: View {

    // List of WeeklySpending structs
    var weeklyData: [WeeklySpending]
    var percentChange: Double

    private var isPositiveChange: Bool { percentChange >= 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            chart
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private var header: some View {
        HStack {
            Text("Spending Trend")
                .font(.urbanist(.bold, size: 18))
                .foregroundStyle(Color.heading)
            Spacer()
            Text(changeLabel)
                .font(.manrope(.bold, size: 12))
                .foregroundStyle(isPositiveChange ? Color.errorRose : Color.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    (isPositiveChange ? Color.errorRose : Color.green).opacity(0.12)
                )
                .clipShape(Capsule())
        }
    }

    private var changeLabel: String {
        let sign = isPositiveChange ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percentChange))%"
    }

    // Attribution: https://developer.apple.com/documentation/charts/linemark
    private var chart: some View {
        Chart(weeklyData) { item in
            // Area mark for the spending trend.
            AreaMark(
                x: .value("Week", item.week),
                y: .value("Amount", item.amount)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.primaryBlue.opacity(0.25), Color.primaryBlue.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            LineMark(
                x: .value("Week", item.week),
                y: .value("Amount", item.amount)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.primaryBlue)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.manrope(.medium, size: 12))
                    .foregroundStyle(Color.mutedText)
            }
        }
        .frame(height: 160)
    }
}

#Preview {
    SpendingTrendCard(
        weeklyData: SpendingTrendCard.sampleData,
        percentChange: 5.4
    )
    .padding(20)
    .background(Color.pageBG)
}

extension SpendingTrendCard {
    static let sampleData: [WeeklySpending] = [
        WeeklySpending(week: "W1", amount: 420),
        WeeklySpending(week: "W2", amount: 680),
        WeeklySpending(week: "W3", amount: 530),
        WeeklySpending(week: "W4", amount: 1750)
    ]
}
