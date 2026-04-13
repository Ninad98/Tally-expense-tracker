//
//  UserProfileSnapshot.swift
//  Tally
//
//  Created by Mazen Tarek on 4/12/26.
//

import Foundation

// Model to hold the user profile data mainly for image storage.
struct UserProfileSnapshot: Sendable {
    var fullName: String
    var email: String
    var profilePhoto: String?
}
