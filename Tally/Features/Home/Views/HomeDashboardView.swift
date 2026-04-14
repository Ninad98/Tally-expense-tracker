//
//  HomeDashboardView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/24/26.
//

import SwiftUI

struct HomeDashboardView: View {

    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedTab: Int // Creates a two-way read and write to selectedTab variable.

    // Controls whether the All Transactions sheet is presented.
    @State private var showAllTransactions: Bool = false

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            if viewModel.isLoading {
                loadingState
            } else {
                content
            }
        }
        .onAppear { viewModel.loadData() }
        // Presents AllTransactionsView as a sheet when See All is tapped.
        .sheet(isPresented: $showAllTransactions) {
            AllTransactionsView()
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

    // Scrollable container for all dashboard sections.
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerRow
                balanceCard
                budgetSection
                incomeExpenseRow
                recentTransactionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }

    // Displays the user's profile avatar, display his name from firebase
    private var headerRow: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    selectedTab = 3
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.primaryBlue)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")

            // Show a dash if name is unable to fetch
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome back,")
                    .font(.manrope(.regular, size: 13))
                    .foregroundStyle(Color.bodyText)
                Text(viewModel.fullName.isEmpty ? "—" : viewModel.fullName)
                    .font(.urbanist(.bold, size: 18))
                    .foregroundStyle(Color.heading)
            }

            Spacer()

            // Code to do in future for notifications
            Button {
                // TODO: Notifications
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.heading)
                    Circle()
                        .fill(Color.errorRose)
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
            }
        }
    }

    // This is for showing total balance
    private var balanceCard: some View {
        VStack(spacing: 12) {
            Text("Total Balance")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.mutedText)

            Text(viewModel.totalBalance.asCurrency())
                .font(.urbanist(.extraBold, size: 36))
                .foregroundStyle(Color.heading)

            if viewModel.balanceChangePercent != 0 {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.balanceChangePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 11, weight: .bold))
                    Text("\(String(format: "%.1f", abs(viewModel.balanceChangePercent)))% this month")
                        .font(.manrope(.medium, size: 13))
                }
                .foregroundStyle(viewModel.balanceChangePercent >= 0 ? Color.green : Color.errorRose)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    (viewModel.balanceChangePercent >= 0 ? Color.green : Color.errorRose).opacity(0.12)
                )
                .clipShape(Capsule())
            } else {
                Text("No data yet") // Shown for users with no transactions
                    .font(.manrope(.medium, size: 13))
                    .foregroundStyle(Color.mutedText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.mutedText.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private var budgetSection: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.35)) {
                selectedTab = 1 // This sets the index to 1 to navigate to BudgetView.
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Monthly Budget")
                        .font(.urbanist(.bold, size: 18))
                        .foregroundStyle(Color.heading)
                    Spacer()
                    Text("Remaining: \(viewModel.budgetRemaining.asCurrency())")
                        .font(.manrope(.medium, size: 13))
                        .foregroundStyle(Color.primaryBlue)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primaryBlue.opacity(0.12))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primaryBlue)
                            .frame(width: geo.size.width * viewModel.budgetProgress, height: 10)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("SPENT: \(viewModel.budgetSpent.asCurrency())")
                        .font(.manrope(.medium, size: 12))
                        .foregroundStyle(Color.mutedText)
                    Spacer()
                    Text("GOAL: \(viewModel.budgetGoal.asCurrency())")
                        .font(.manrope(.medium, size: 12))
                        .foregroundStyle(Color.mutedText)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var incomeExpenseRow: some View {
        HStack(spacing: 16) {
            summaryCard(title: "Income", amount: viewModel.monthlyIncome, isIncome: true)
            summaryCard(title: "Expenses", amount: viewModel.monthlyExpenses, isIncome: false)
        }
    }

    private func summaryCard(title: String, amount: Double, isIncome: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill((isIncome ? Color.green : Color.errorRose).opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: isIncome ? "arrow.down" : "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isIncome ? Color.green : Color.errorRose)
            }

            Text(title)
                .font(.manrope(.medium, size: 13))
                .foregroundStyle(Color.mutedText)

            Text(amount.asCurrency())
                .font(.urbanist(.bold, size: 20))
                .foregroundStyle(isIncome ? Color.green : Color.errorRose)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private var recentTransactionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.urbanist(.bold, size: 18))
                    .foregroundStyle(Color.heading)
                Spacer()
                // Tapping See All opens AllTransactionsView as a sheet.
                Button("See All") {
                    showAllTransactions = true
                }
                .font(.manrope(.bold, size: 14))
                .foregroundStyle(Color.primaryBlue)
            }

            if viewModel.recentTransactions.isEmpty {
                emptyTransactions
            } else {
                VStack(spacing: 0) {
                    // Swipe left on any row to reveal the red Delete button.
                    // allowsFullSwipe: true means a full swipe deletes without tapping the button.
                    ForEach(viewModel.recentTransactions) { transaction in
                        transactionRow(transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        if transaction.id != viewModel.recentTransactions.last?.id {
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
            }
        }
    }

    // This is for no transactions
    private var emptyTransactions: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(Color.mutedText)
            Text("No transactions yet")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private func transactionRow(_ transaction: AppTransaction) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryBlue.opacity(0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: transaction.categoryIcon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 3) {
                // Added an HStack to display the recurring icon indication in recent transactions if it was a recurring one.
                HStack(spacing: 6) {
                    Text(transaction.title)
                        .font(.manrope(.bold, size: 15))
                        .foregroundStyle(Color.heading)
                    if transaction.isRecurring, !transaction.isIncome {
                        Image(systemName: "repeat")
                            .font(.system(size: 11, weight: .semibold))
                            // Change the icon color to mutedText if the recurring transaction is paused.
                            .foregroundStyle(transaction.isRecurringPaused ? Color.mutedText : Color.primaryBlue)
                    }
                }
                Text(recurringTransactionSubtitle(transaction))
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.mutedText)
            }

            Spacer()

            Text((transaction.isIncome ? "+" : "-") + formatCurrency(transaction.amount))
                .font(.urbanist(.bold, size: 16))
                .foregroundStyle(transaction.isIncome ? Color.green : Color.errorRose)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // This appends Monthly or Paused in the subtitle of a transaction if it was a recurring one.
    private func recurringTransactionSubtitle(_ transaction: AppTransaction) -> String {
        var parts: [String] = [transaction.categoryName]
        if transaction.isRecurring, !transaction.isIncome {
            parts.append(transaction.isRecurringPaused ? "Paused" : "Monthly")
        }
        parts.append(formatDate(transaction.date))
        return parts.joined(separator: " • ")
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    HomeDashboardView(viewModel: HomeViewModel(), selectedTab: .constant(0))
}
