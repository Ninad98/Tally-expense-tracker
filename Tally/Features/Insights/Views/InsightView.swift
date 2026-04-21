//
//  InsightView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/24/26.
//

import Charts
import SwiftUI

struct InsightsView: View {

    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            if viewModel.isLoading {
                loadingState
            } else {
                mainContent
            }
        }
        .onAppear { viewModel.loadData() }
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            viewModel.loadData()
        }
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.primaryBlue)
            Text("Loading...")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.mutedText)
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerRow
                periodToggle
                donutChartSection
                categoryBreakdownSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }

    private var headerRow: some View {
        Text("Spending Insights")
            .font(.urbanist(.bold, size: 22))
            .foregroundStyle(Color.heading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
    // Segmented control for Week / Month / Year.
    private var periodToggle: some View {
        HStack(spacing: 0) {
            ForEach(InsightsPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.manrope(.bold, size: 14))
                        .foregroundStyle(
                            viewModel.selectedPeriod == period ? Color.primaryBlue : Color.mutedText
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            viewModel.selectedPeriod == period
                                ? Color.primaryBlue.opacity(0.1) : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }

    // Ring chart with total spent and % change in the center.
    private var donutChartSection: some View {
        ZStack {
            if viewModel.categoryBreakdowns.isEmpty {
                // Show an empty ring when there are no transactions.
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.12), lineWidth: 28)
                    .frame(width: 220, height: 220)
            } else {
                // Swift Charts SectorMark for the donut rings.
                Chart(viewModel.categoryBreakdowns) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.65),
                        angularInset: 2
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(4)
                }
                .frame(width: 220, height: 220)
            }

            // Center overlay showing total and % change.
            VStack(spacing: 4) {
                Text("Total Spent")
                    .font(.manrope(.medium, size: 13))
                    .foregroundStyle(Color.mutedText)

                Text(viewModel.totalSpent.asCurrency())
                    .font(.urbanist(.extraBold, size: 22))
                    .foregroundStyle(Color.heading)

                if viewModel.percentageChange != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.percentageChange < 0 ? "arrow.down.right" : "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(String(format: "%.0f", abs(viewModel.percentageChange)))% \(viewModel.periodComparisonLabel)")
                            .font(.manrope(.medium, size: 11))
                    }
                    // Green when spending decreased, red when increased.
                    .foregroundStyle(viewModel.percentageChange < 0 ? Color.green : Color.errorRose)
                } else {
                    Text("No prior data")
                        .font(.manrope(.medium, size: 11))
                        .foregroundStyle(Color.mutedText)
                }
            }
        }
        .padding(.vertical, 16)
    }

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.urbanist(.bold, size: 18))
                .foregroundStyle(Color.heading)

            if viewModel.categoryBreakdowns.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.categoryBreakdowns) { item in
                        categoryRow(item)
                        if item.id != viewModel.categoryBreakdowns.last?.id {
                            Divider()
                                .padding(.leading, 68)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
            }
        }
    }

    // Empty state when no expense transactions exist for the period.
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 36))
                .foregroundStyle(Color.mutedText)
            Text("No expenses this period")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    // Single category row showing icon, name, % of total, and amount.
    private func categoryRow(_ item: CategoryInsight) -> some View {
        HStack(spacing: 14) {

            // Colored icon background matching the donut segment color.
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(item.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.manrope(.bold, size: 15))
                    .foregroundStyle(Color.heading)
                Text("\(String(format: "%.0f", item.percentage))% of total spend")
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.mutedText)
            }

            Spacer()

            Text(item.amount.asCurrency())
                .font(.urbanist(.bold, size: 16))
                .foregroundStyle(Color.heading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    InsightsView()
}
