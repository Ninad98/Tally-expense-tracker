//
//  Bundle+AppVersion.swift
//  Tally
//
//  Created by Mazen Tarek on 4/17/26.
//

import Foundation

extension Bundle {

    // Attribution: https://stackoverflow.com/questions/24501288/getting-version-and-build-information-with-swift
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "—"
    }

    var appBuild: String {
        (infoDictionary?["CFBundleVersion"] as? String) ?? "—"
    }
}
