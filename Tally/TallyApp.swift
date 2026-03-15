//
//  TallyApp.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import SwiftUI

@main
struct TallyApp: App {
    @AppStorage("splashShown") private var splashShown: Bool = false
    @State private var splashDismissed: Bool = false

    var body: some Scene {
        WindowGroup {
            if !splashShown && !splashDismissed {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                splashShown = true
                                splashDismissed = true
                            }
                        }
                    }
            } else {
                HomeView()
            }
        }
    }
}
