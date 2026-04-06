//
//  RecurringPaymentsSheet.swift
//  Tally
//
//  Created by Mazen Tarek on 4/5/26.
//

import SwiftUI

struct RecurringPaymentsSheet: View {

    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) private var dismiss

    private var transactions: [AppTransaction] { viewModel.recurringExpenseTransactions }

    // Attribution: GenAI helped me a bit in some of the design aspects here, mainly the summary hero card design.
    var body: some View {
        NavigationStack {
            Group {
                if transactions.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            summaryHeroCard

                            HStack(alignment: .center) {
                                Text("Active Subscriptions")
                                    .font(.urbanist(.bold, size: 18))
                                    .foregroundStyle(Color.heading)
                                Spacer()
                                Text("\(viewModel.activeRecurringSubscriptionCount) Total")
                                    .font(.manrope(.bold, size: 12))
                                    .foregroundStyle(Color.primaryBlue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.primaryBlue.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 4)

                            VStack(spacing: 12) {
                                ForEach(transactions) { transaction in
                                    subscriptionRow(transaction)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pageBG.ignoresSafeArea())
            .navigationTitle("Recurring Expenses")
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
    }

    private var summaryHeroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOTAL MONTHLY RECURRING")
                .font(.manrope(.bold, size: 11))
                .foregroundStyle(.white.opacity(0.9))
                .tracking(0.6)

            Text(viewModel.totalActiveRecurringAmount.asCurrency())
                .font(.urbanist(.extraBold, size: 32))
                .foregroundStyle(.white)

            if let next = viewModel.nextActiveRecurringPaymentDate {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Next payment: \(dueDayFormatter.string(from: next))")
                        .font(.manrope(.bold, size: 13))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.22))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.primaryBlue.opacity(0.14), radius: 10, x: 0, y: 5)
    }

    private var dueDayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }

    // This is when the user has no recurring expenses, displayes a message and icon for an empty state.
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.left.arrow.right.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color.mutedText)
            Text("No recurring payments this month")
                .font(.manrope(.bold, size: 16))
                .foregroundStyle(Color.heading)
            Text("Mark expenses as recurring when you add them to see them here.")
                .font(.manrope(.regular, size: 14))
                .foregroundStyle(Color.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func subscriptionRow(_ transaction: AppTransaction) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryBlue.opacity(0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: transaction.categoryIcon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.manrope(.bold, size: 15))
                    .foregroundStyle(Color.heading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(recurringRowSubtext(transaction))
                    .font(.manrope(.medium, size: 12))
                    .foregroundStyle(Color.mutedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(-1)

            Toggle("", isOn: Binding(
                get: { !transaction.isRecurringPaused },
                set: { isActive in
                    viewModel.setRecurringPaused(transactionId: transaction.id, paused: !isActive)
                }
            ))
            .labelsHidden()
            .tint(Color.primaryBlue)
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func recurringRowSubtext(_ transaction: AppTransaction) -> String {
        let priceMo = "\(transaction.amount.asCurrency())/mo"
        if transaction.isRecurringPaused {
            return "\(priceMo) • Paused"
        }
        let nextDue = Date.nextRecurringDueDate(
            fromAnchor: transaction.date,
            includeSameDayAsReference: false
        )
        return "\(priceMo) • Due \(dueDayFormatter.string(from: nextDue))"
    }
}

#Preview {
    RecurringPaymentsSheet(viewModel: BudgetViewModel())
}
