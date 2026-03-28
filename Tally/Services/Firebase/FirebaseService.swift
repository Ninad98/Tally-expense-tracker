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

        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
        try await ref.setData(data)
    }
}
