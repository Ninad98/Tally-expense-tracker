//
//  AllTransactionsView.swift
//  Tally
//
//  Created by Ninad Mankar on 4/11/26.
//


import SwiftUI

struct AllTransactionsView: View {

    @StateObject private var viewModel = AllTransactionsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageBG.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingState
                } else if viewModel.allTransactions.isEmpty {
                    emptyState
                } else {
                    transactionList
                }
            }
            .navigationTitle("All Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.primaryBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear { viewModel.loadTransactions() }
        .preferredColorScheme(.light)
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.primaryBlue)
            Text("Loading...")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.mutedText)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(Color.mutedText)
            Text("No transactions yet")
                .font(.urbanist(.bold, size: 20))
                .foregroundStyle(Color.heading)
            Text("Add your first transaction using the + button.")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var transactionList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Summary card at the top showing overall income vs expenses.
                summaryCard

                // Each group is a month with its transactions listed below.
                ForEach(viewModel.groupedTransactions, id: \.month) { group in
                    monthSection(group)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
    }

    // Shows total income vs total expenses across all time.
    private var summaryCard: some View {
        HStack(spacing: 16) {
            summaryPill(
                title: "Total Income",
                amount: viewModel.totalIncome,
                isIncome: true
            )
            summaryPill(
                title: "Total Expenses",
                amount: viewModel.totalExpenses,
                isIncome: false
            )
        }
    }

    private func summaryPill(title: String, amount: Double, isIncome: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill((isIncome ? Color.green : Color.errorRose).opacity(0.12))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: isIncome ? "arrow.down" : "arrow.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(isIncome ? Color.green : Color.errorRose)
                    )
                Text(title)
                    .font(.manrope(.medium, size: 12))
                    .foregroundStyle(Color.mutedText)
            }
            Text(amount.asCurrency())
                .font(.urbanist(.bold, size: 18))
                .foregroundStyle(isIncome ? Color.green : Color.errorRose)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // Renders a month header followed by all transactions in that month.
    private func monthSection(_ group: (month: String, transactions: [AppTransaction])) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.month.uppercased())
                .font(.manrope(.bold, size: 12))
                .foregroundStyle(Color.mutedText)
                .tracking(0.6)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(group.transactions) { transaction in
                    transactionRow(transaction)
                        // Swipe left to reveal the delete button.
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteTransaction(transaction)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    if transaction.id != group.transactions.last?.id {
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

    // Same row style as HomeDashboardView for visual consistency.
    private func transactionRow(_ transaction: AppTransaction) -> some View {
        HStack(spacing: 16) {

            // Category icon in rounded square background.
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryBlue.opacity(0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: transaction.categoryIcon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 3) {
                // Title row with optional recurring icon.
                HStack(spacing: 6) {
                    Text(transaction.title)
                        .font(.manrope(.bold, size: 15))
                        .foregroundStyle(Color.heading)
                    if transaction.isRecurring, !transaction.isIncome {
                        Image(systemName: "repeat")
                            .font(.system(size: 11, weight: .semibold))
                            // Muted color if paused, blue if active.
                            .foregroundStyle(
                                transaction.isRecurringPaused ? Color.mutedText : Color.primaryBlue
                            )
                    }
                }

                Text(subtitleText(transaction))
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.mutedText)
            }

            Spacer()

            Text((transaction.isIncome ? "+" : "-") + transaction.amount.asCurrency())
                .font(.urbanist(.bold, size: 16))
                .foregroundStyle(transaction.isIncome ? Color.green : Color.errorRose)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // Builds the subtitle string, appending Monthly/Paused for recurring transactions.
    private func subtitleText(_ transaction: AppTransaction) -> String {
        var parts: [String] = [transaction.categoryName]
        if transaction.isRecurring, !transaction.isIncome {
            parts.append(transaction.isRecurringPaused ? "Paused" : "Monthly")
        }
        parts.append(formatDate(transaction.date))
        return parts.joined(separator: " • ")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    AllTransactionsView()
}
