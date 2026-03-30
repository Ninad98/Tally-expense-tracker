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

    func fetchActiveBudget(uid: String) async -> Budget? {
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users").document(uid)
                .collection("budgets").limit(to: 1).getDocuments()

            guard let doc = snapshot.documents.first 
            else { 
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
        for cat in categoryLimits {
            totalLimit += cat.limit
        }

        // This is the opposite of what we did in fetchActiveBudget(), here we convert our
        // CategoryLimit model into a dict that can be saved to firestore.
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

}
