//
//  FirebaseService.swift
//  Tally
//
//  Created by Mazen Tarek on 3/28/26.
//

import FirebaseFirestore
import Foundation

final class FirebaseService: FirebaseServiceProtocol {

    func saveUserToFirestore(uid: String, email: String, fullName: String, selectedCurrencyId: String?) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)

        let snapshot = try await ref.getDocument()
        if snapshot.exists {
            print("User already exists in firestore.")
            return
        }

        var data: [String: Any] = [
            "email": email,
            "fullName": fullName,
            "createdAt": FieldValue.serverTimestamp()
        ]

        if let currencyId = selectedCurrencyId {
            data["selectedCurrencyId"] = currencyId
        }

        try await ref.setData(data)
    }

    func fetchUserFullName(uid: String) async -> String? {
        do {
            let db = Firestore.firestore()
            let fetchedUser = try await db.collection("users").document(uid).getDocument()
            guard fetchedUser.exists,
                  let name = fetchedUser.data()?["fullName"] as? String,
                  !name.isEmpty else { return nil }
            return name
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    func fetchActiveBudget(uid: String) async -> Budget? {
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users").document(uid)
                .collection("budgets").limit(to: 1).getDocuments()

            guard let doc = snapshot.documents.first else {
                print("No budget found for user.")
                return nil
            }

            let data = doc.data()

            var categories: [CategoryLimit] = []
            if let firestoreCategoryLimits = data["categoryLimits"] as? [[String: Any]] {
                for item in firestoreCategoryLimits {
                    let category = CategoryLimit(
                        id: item["categoryId"] as? String ?? "",
                        name: item["name"] as? String ?? "",
                        description: item["description"] as? String ?? "",
                        icon: item["icon"] as? String ?? "questionmark",
                        limit: item["limit"] as? Double ?? 0
                    )
                    categories.append(category)
                }
            }

            return Budget(
                id: doc.documentID,
                name: data["name"] as? String ?? "Monthly Budget",
                period: data["period"] as? String ?? "monthly",
                totalLimitBase: data["totalLimitBase"] as? Double ?? 0,
                categoryLimits: categories,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
            )
        } catch {
            print("Error fetching budget: \(error.localizedDescription).")
            return nil
        }
    }

    func saveBudget(uid: String, categoryLimits: [CategoryLimit], existingBudgetId: String?) async throws {
        let db = Firestore.firestore()
        let budgetsRef = db.collection("users").document(uid).collection("budgets")

        var totalLimit = 0.0
        for cat in categoryLimits { totalLimit += cat.limit }

        let categoriesData: [[String: Any]] = categoryLimits.map { cat in
            [
                "categoryId": cat.id,
                "name": cat.name,
                "description": cat.description,
                "icon": cat.icon,
                "limit": cat.limit
            ]
        }

        var data: [String: Any] = [
            "name": "Monthly Budget",
            "period": "monthly",
            "totalLimitBase": totalLimit,
            "categoryLimits": categoriesData,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if existingBudgetId == nil {
            data["createdAt"] = FieldValue.serverTimestamp()
        }

        let ref = existingBudgetId != nil
            ? budgetsRef.document(existingBudgetId!)
            : budgetsRef.document()

        try await ref.setData(data, merge: existingBudgetId != nil)
    }


    func addTransaction(
        uid: String,
        title: String,
        amount: Double,
        categoryId: String,
        categoryName: String,
        categoryIcon: String,
        type: TransactionType,
        date: Date,
        note: String
    ) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
            .collection("transactions").document()

        let data: [String: Any] = [
            "title": title,
            "amount": amount,
            "categoryId": categoryId,
            "categoryName": categoryName,
            "categoryIcon": categoryIcon,
            "type": type.rawValue,
            "date": Timestamp(date: date),
            "note": note,
            "createdAt": FieldValue.serverTimestamp()
        ]

        try await ref.setData(data)
    }

    func fetchRecentTransactions(uid: String, limit: Int) async -> [AppTransaction] {
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users").document(uid)
                .collection("transactions")
                .order(by: "date", descending: true)
                .limit(to: limit)
                .getDocuments()

            return snapshot.documents.compactMap { mapTransaction($0) }
        } catch {
            print("Error fetching recent transactions: \(error.localizedDescription)")
            return []
        }
    }

    func fetchMonthlyTransactions(uid: String) async -> [AppTransaction] {
        do {
            let db = Firestore.firestore()
            let calendar = Calendar.current
            let now = Date()
            guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                return []
            }

            let snapshot = try await db.collection("users").document(uid)
                .collection("transactions")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: monthStart))
                .whereField("date", isLessThan: Timestamp(date: monthEnd))
                .order(by: "date", descending: true)
                .getDocuments()

            return snapshot.documents.compactMap { mapTransaction($0) }
        } catch {
            print("Error fetching monthly transactions: \(error.localizedDescription)")
            return []
        }
    }


    private func mapTransaction(_ doc: QueryDocumentSnapshot) -> AppTransaction? {
        let data = doc.data()
        guard
            let title = data["title"] as? String,
            let amount = data["amount"] as? Double,
            let typeStr = data["type"] as? String,
            let type = TransactionType(rawValue: typeStr),
            let dateTimestamp = data["date"] as? Timestamp
        else { return nil }

        return AppTransaction(
            id: doc.documentID,
            title: title,
            amount: amount,
            categoryId: data["categoryId"] as? String ?? "",
            categoryName: data["categoryName"] as? String ?? "",
            categoryIcon: data["categoryIcon"] as? String ?? "questionmark",
            type: type,
            date: dateTimestamp.dateValue(),
            note: data["note"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? dateTimestamp.dateValue()
        )
    }
}
