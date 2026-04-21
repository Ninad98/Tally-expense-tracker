//
//  InsightsViewModel.swift
//  Tally
//
//  Created by Ninad Mankar on 4/20/26.
//

import Charts
import Combine
import FirebaseAuth
import SwiftUI

// The three time periods the user can select.
enum InsightsPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

// Holds spending data for a single category.
struct CategoryInsight: Identifiable {
    let id: String
    let name: String
    let icon: String
    let amount: Double
    let percentage: Double
    let color: Color
}

final class InsightsViewModel: ObservableObject {

    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    @Published var selectedPeriod: InsightsPeriod = .month
    @Published var isLoading: Bool = true
    @Published var totalSpent: Double = 0
    @Published var totalIncome: Double = 0

    // Positive = spending increased vs last period, negative = decreased.
    @Published var percentageChange: Double = 0
    @Published var categoryBreakdowns: [CategoryInsight] = []

    func loadData() {
        isLoading = true
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }

        let (currentStart, currentEnd) = dateRange(for: selectedPeriod, offset: 0)
        let (prevStart, prevEnd) = dateRange(for: selectedPeriod, offset: -1)

        Task {
            // Fetch current and previous period simultaneously.
            async let current = firebaseService.fetchTransactions(uid: uid, from: currentStart, to: currentEnd)
            async let previous = firebaseService.fetchTransactions(uid: uid, from: prevStart, to: prevEnd)

            let (currentTx, previousTx) = await (current, previous)

            await MainActor.run {
                let currentExpenses = currentTx.filter { !$0.isIncome }
                let prevExpenses = previousTx.filter { !$0.isIncome }

                totalSpent = currentExpenses.reduce(0) { $0 + $1.amount }
                totalIncome = currentTx.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }

                let prevTotal = prevExpenses.reduce(0) { $0 + $1.amount }
                if prevTotal > 0 {
                    percentageChange = ((totalSpent - prevTotal) / prevTotal) * 100
                } else {
                    percentageChange = 0
                }

                categoryBreakdowns = buildCategoryBreakdowns(from: currentExpenses)
                isLoading = false
            }
        }
    }

    // Label shown next to % change e.g. "vs last month"
    var periodComparisonLabel: String {
        switch selectedPeriod {
        case .week: return "vs last week"
        case .month: return "vs last month"
        case .year: return "vs last year"
        }
    }

    // Groups transactions by category and calculates % of total for each.
    private func buildCategoryBreakdowns(from transactions: [AppTransaction]) -> [CategoryInsight] {
        var dict: [String: (name: String, icon: String, amount: Double)] = [:]
        for tx in transactions {
            if let existing = dict[tx.categoryId] {
                dict[tx.categoryId] = (existing.name, existing.icon, existing.amount + tx.amount)
            } else {
                dict[tx.categoryId] = (tx.categoryName, tx.categoryIcon, tx.amount)
            }
        }

        let total = dict.values.reduce(0) { $0 + $1.amount }

        return dict.enumerated().map { index, pair in
            CategoryInsight(
                id: pair.key,
                name: pair.value.name,
                icon: pair.value.icon,
                amount: pair.value.amount,
                percentage: total > 0 ? (pair.value.amount / total) * 100 : 0,
                color: categoryColor(for: index)
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    // Assigns a distinct color to each category by index.
    private func categoryColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color.primaryBlue, .green, .orange, .purple,
            .red, .teal, .pink, Color(red: 1, green: 0.8, blue: 0)
        ]
        return colors[index % colors.count]
    }

    // Returns start and end Date for a given period and offset.
    // offset 0 = current period, offset -1 = previous period.
    private func dateRange(for period: InsightsPeriod, offset: Int) -> (Date, Date) {
        let cal = Calendar.current
        let now = Date()

        switch period {
        case .week:
            let startOfWeek = cal.date(
                from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            ) ?? now
            let start = cal.date(byAdding: .weekOfYear, value: offset, to: startOfWeek) ?? now
            let end = cal.date(byAdding: .weekOfYear, value: 1, to: start) ?? now
            return (start, end)

        case .month:
            let startOfMonth = cal.date(
                from: cal.dateComponents([.year, .month], from: now)
            ) ?? now
            let start = cal.date(byAdding: .month, value: offset, to: startOfMonth) ?? now
            let end = cal.date(byAdding: .month, value: 1, to: start) ?? now
            return (start, end)

        case .year:
            let startOfYear = cal.date(
                from: cal.dateComponents([.year], from: now)
            ) ?? now
            let start = cal.date(byAdding: .year, value: offset, to: startOfYear) ?? now
            let end = cal.date(byAdding: .year, value: 1, to: start) ?? now
            return (start, end)
        }
    }
}
