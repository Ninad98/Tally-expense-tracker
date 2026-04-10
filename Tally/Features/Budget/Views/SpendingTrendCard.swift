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

    // This is for the pointmarks on the chart to show the amount.
    @State private var selectedWeek: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Trend")
                .font(.urbanist(.bold, size: 18))
                .foregroundStyle(Color.heading)
            chart
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
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

            PointMark(
                x: .value("Week", item.week),
                y: .value("Amount", item.amount)
            )
            .symbolSize(item.week == selectedWeek ? 64 : 36)
            .foregroundStyle(Color.primaryBlue)
            .annotation(position: .top, spacing: 8) {
                if item.week == selectedWeek {
                    Text(item.amount.asCurrency())
                        .font(.manrope(.bold, size: 12))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primaryBlue)
                        .clipShape(Capsule())
                }
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.manrope(.medium, size: 12))
                    .foregroundStyle(Color.mutedText)
            }
        }
        // Attribution: GenAI helped me draw the amount as an overlay on the chart.
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        guard let week: String = proxy.value(atX: location.x) else { return }
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedWeek = (selectedWeek == week) ? nil : week
                        }
                    }
            }
        }
        .frame(height: 160)
    }
}

#Preview {
    SpendingTrendCard(weeklyData: SpendingTrendCard.sampleData)
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
