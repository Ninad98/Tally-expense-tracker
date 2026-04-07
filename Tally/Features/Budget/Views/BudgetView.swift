//
//  BudgetView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/24/26.
//

//
//  BudgetView.swift
//  Tally
//

import SwiftUI

struct BudgetView: View {

    @StateObject private var viewModel = BudgetViewModel()
    @State private var showEditLimits = false
    @State private var showRecurringPayments = false

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()
            
            // wwhen loading show progressview that is built in.
            if viewModel.isLoading {
                ProgressView()
                    .tint(Color.primaryBlue)
            } else {
                budgetContent
            }
        }
        .onAppear { viewModel.loadBudget() }
        .sheet(isPresented: $showEditLimits) {
            EditLimitsView(
                existingBudget: viewModel.budget,
                onSave: { viewModel.loadBudget() }
            )
        }
        .sheet(isPresented: $showRecurringPayments) {
            RecurringPaymentsSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationBackground(Color.pageBG)
                .presentationDragIndicator(.visible)
        }
    }

    private var budgetContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                summaryCard
                recurringPaymentsCard
                categoryBreakdown
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }

    // Minimal Header section contains current month, year and title Monthly Budget
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentMonthYear.uppercased())
                    .font(.manrope(.medium, size: 12))
                    .foregroundStyle(Color.mutedText)
                Text("Monthly Budget")
                    .font(.urbanist(.bold, size: 22))
                    .foregroundStyle(Color.heading)
            }
            Spacer()
        }
    }


    private var recurringPaymentsCard: some View {
        Button {
            showRecurringPayments = true
        } label: {
            HStack(alignment: .center, spacing: 14) {
                // To make the icon pop out on the button.
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 44, height: 44)
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Recurring Payments")
                        .font(.manrope(.bold, size: 16))
                        .foregroundStyle(.white)
                    Text(recurringPaymentsSubtitle)
                        .font(.manrope(.medium, size: 13))
                        .foregroundStyle(.white.opacity(0.88))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    // Since the count is dynamic we calculate the subtitle based on the count.
    private var recurringPaymentsSubtitle: String {
        let n = viewModel.activeRecurringSubscriptionCount
        if n == 0 {
            return "No active subscriptions"
        }
        else if n == 1 {
            return "Manage your active subscription"
        }
        return "Manage your \(n) active subscriptions"
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Budget Status")
                        .font(.manrope(.medium, size: 13))
                        .foregroundStyle(Color.mutedText)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(viewModel.totalSpent.asCurrency())
                            .font(.urbanist(.extraBold, size: 28))
                            .foregroundStyle(Color.heading)
                        Text("/ \(viewModel.totalLimit.asCurrency())")
                            .font(.manrope(.medium, size: 16))
                            .foregroundStyle(Color.mutedText)
                    }
                }
                Spacer()
            }
            
            // Attribution: GenAI helped me create the design for this progress bar.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primaryBlue.opacity(0.12))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primaryBlue)
                        .frame(width: geo.size.width * viewModel.progress, height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text("Remaining: \(viewModel.totalRemaining.asCurrency())")
                    .font(.manrope(.medium, size: 12))
                    .foregroundStyle(Color.mutedText)
                Spacer()
                Button("Edit Limits") {
                    showEditLimits = true
                }
                .font(.manrope(.bold, size: 13))
                .foregroundStyle(Color.primaryBlue)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // Displays all the categories created for the logged in user
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.urbanist(.bold, size: 18))
                .foregroundStyle(Color.heading)

            if viewModel.categoryLimits.isEmpty {
                Text("No categories created yet.")
                    .font(.manrope(.medium, size: 14))
                    .foregroundStyle(Color.mutedText)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.categoryLimits) { category in
                        categoryRow(category)
                        // Do not add a divider for the last category, just for the ones before it.
                        if category.id != viewModel.categoryLimits.last?.id {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
            }
        }
    }

    // Similar to the progress bar in total budget status.
    private func categoryRow(_ category: CategoryLimit) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primaryBlue.opacity(0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.manrope(.bold, size: 15))
                    .foregroundStyle(Color.heading)
                Text("limit \(category.limit.asCurrency())")
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.mutedText)
            }

            Spacer()

            Text(viewModel.spentForCategory(category.id).asCurrency())
                .font(.urbanist(.bold, size: 16))
                .foregroundStyle(
                    viewModel.spentForCategory(category.id) > 0 ? Color.errorRose : Color.heading
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showEditLimits = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                    Text("Edit Limits")
                }
                .font(.manrope(.bold, size: 14))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                // TODO: History modal, might remove it
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .font(.manrope(.bold, size: 14))
                .foregroundStyle(Color.heading)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
            }
        }
    }

}

#Preview {
    BudgetView()
}
