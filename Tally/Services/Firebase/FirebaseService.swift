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

        // Check first if user exists before creating a new entry in firestore.
        let snapshot = try await ref.getDocument()
        if snapshot.exists {
            print("User already exists in firestore.")
            return
        }

        var data: [String: Any] = [
            "email": email,
            "fullName": fullName,
            "createdAt": FieldValue.serverTimestamp() // sets timestamp to current server time
        ]

        // Getting selected currency in onboarding stage to link it to user.
        if let currencyId = selectedCurrencyId {
            data["selectedCurrencyId"] = currencyId
            print("Selected currency: \(currencyId)")
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

    func fetchUserProfile(uid: String) async -> UserProfileSnapshot? {
        do {
            let db = Firestore.firestore()
            let doc = try await db.collection("users").document(uid).getDocument()

            // If document doesn't exist we return nil and print error.
            guard doc.exists, let data = doc.data() else { 
                print("User profile document does not exist.")
                return nil 
            }

            let fullName = data["fullName"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let photo = (data["profilePhoto"] as? String) ?? (data["profilePhotoJPEGBase64"] as? String)
            let plaidItemID = data["plaidItemID"] as? String
            let rawInstitutionName = data["plaidInstitutionName"] as? String
            let plaidInstitutionName = (rawInstitutionName?.isEmpty == true) ? nil : rawInstitutionName
            let plaidLinkedAt = (data["plaidLinkedAt"] as? Timestamp)?.dateValue()

            return UserProfileSnapshot(
                fullName: fullName,
                email: email,
                profilePhoto: photo,
                plaidItemID: plaidItemID,
                plaidInstitutionName: plaidInstitutionName,
                plaidLinkedAt: plaidLinkedAt
            )
        } catch {
            print("fetchUserProfile error")
            return nil
        }
    }

    func updateUserImage(uid: String, jpegBase64: String) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
        try await ref.setData(["profilePhoto": jpegBase64], merge: true)
    }

    func updateUserFullName(uid: String, fullName: String) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
        try await ref.setData(["fullName": fullName], merge: true)
    }

    func savePlaidLink(uid: String, itemID: String, institutionName: String?) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)

        let data: [String: Any] = [
            "plaidItemID": itemID,
            "plaidLinkedAt": FieldValue.serverTimestamp(),
            "plaidInstitutionName": institutionName ?? ""
        ]

        try await ref.setData(data, merge: true)
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

            // Converts firestore dict data into our CategoryLimit model.
            var categories: [CategoryLimit] = []
            if let firestoreCategoryLimits = data["categoryLimits"] as? [[String: Any]] {
                for item in firestoreCategoryLimits {
                    let category = CategoryLimit(
                        id: item["categoryId"] as? String ?? "",
                        name: item["name"] as? String ?? "",
                        description: item["description"] as? String ?? "",
                        icon: item["icon"] as? String ?? "questionmark",
                        limit: item["limit"] as? Double ?? 0,
                        isCustom: item["isCustom"] as? Bool ?? false
                    )
                    categories.append(category)
                }
            }
            
            // Adds plaid category and income category if they do not exist yet.
            if !categories.contains(where: { $0.id == "plaid" }) {
                categories.append(
                    CategoryLimit(
                        id: "plaid",
                        name: "Plaid Imports",
                        description: "Imported transactions that did not match app categories",
                        icon: "link",
                        limit: 0,
                        isCustom: false
                    )
                )
            }
            if !categories.contains(where: { $0.id == "income" }) {
                categories.append(
                    CategoryLimit(
                        id: "income",
                        name: "Income",
                        description: "Salary, refunds, and other income",
                        icon: "arrow.down.left.circle.fill",
                        limit: 0,
                        isCustom: false
                    )
                )
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

        // This is the opposite of what we did in fetchActiveBudget(), here we convert our
        // CategoryLimit model into a dict that can be saved to firestore.
        let categoriesData: [[String: Any]] = categoryLimits.map { cat in
            [
                "categoryId": cat.id,
                "name": cat.name,
                "description": cat.description,
                "icon": cat.icon,
                "limit": cat.limit,
                "isCustom": cat.isCustom
            ]
        }

        var data: [String: Any] = [
            "name": "Monthly Budget",
            "period": "monthly",
            "totalLimitBase": totalLimit,
            "categoryLimits": categoriesData,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        // Create a new budget entry if it doesn't exist yet.
        if existingBudgetId == nil {
            data["createdAt"] = FieldValue.serverTimestamp()
        }

        let ref = existingBudgetId != nil
            ? budgetsRef.document(existingBudgetId!)
            : budgetsRef.document()

        // If budget document already exists, we merge the changes into it.
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
        note: String,
        isRecurring: Bool
    ) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
            .collection("transactions").document()

        var data: [String: Any] = [
            "title": title,
            "amount": amount,
            "categoryId": categoryId,
            "categoryName": categoryName,
            "categoryIcon": categoryIcon,
            "type": type.rawValue,
            "date": Timestamp(date: date),
            "note": note,
            "isRecurring": isRecurring,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if isRecurring {
            data["isRecurringPaused"] = false
        }

        try await ref.setData(data)
    }

    func updateTransactionRecurringPaused(uid: String, transactionId: String, paused: Bool) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
            .collection("transactions").document(transactionId)
        try await ref.updateData(["isRecurringPaused": paused])
    }

    func importPlaidTransaction(uid: String, plaidTransactionId: String,
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
        let collection = db.collection("users").document(uid).collection("transactions")
        let existing = try await collection
            .whereField("plaidTransactionId", isEqualTo: plaidTransactionId)
            .limit(to: 1)
            .getDocuments()

        let ref = existing.documents.first?.reference ?? collection.document()
        var data: [String: Any] = [
            "plaidTransactionId": plaidTransactionId,
            "title": title,
            "amount": amount,
            "categoryId": categoryId,
            "categoryName": categoryName,
            "categoryIcon": categoryIcon,
            "type": type.rawValue,
            "date": Timestamp(date: date),
            "note": note,
            "isRecurring": false,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if existing.documents.isEmpty {
            data["createdAt"] = FieldValue.serverTimestamp()
        }
        try await ref.setData(data, merge: true)
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

        let isRecurring = data["isRecurring"] as? Bool ?? false
        let isRecurringPaused = (data["isRecurringPaused"] as? Bool)
            ?? (data["recurringPaused"] as? Bool) ?? false

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
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? dateTimestamp.dateValue(),
            isRecurring: isRecurring,
            isRecurringPaused: isRecurringPaused
        )
    }
    
    func fetchAllTransactions(uid: String) async -> [AppTransaction] {
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users").document(uid)
                .collection("transactions")
                .order(by: "date", descending: true)
                .getDocuments()
            return snapshot.documents.compactMap { mapTransaction($0) }
        } catch {
            print("Error fetching all transactions: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteTransaction(uid: String, transactionId: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("users").document(uid)
            .collection("transactions").document(transactionId)
            .delete()
    }
}
