//
//  Transaction.swift
//  Tally
//
//  Created by Ninad Mankar on 3/30/26.
//


import Foundation

enum TransactionType: String, CaseIterable {
    case expense = "expense"
    case income = "income"
}

struct AppTransaction: Identifiable {
    let id: String
    let title: String
    let amount: Double
    let categoryId: String
    let categoryName: String
    let categoryIcon: String
    let type: TransactionType
    let date: Date
    let note: String
    let createdAt: Date
    let isRecurring: Bool
    let isRecurringPaused: Bool

    var isIncome: Bool { type == .income }
}
