//
//  TallyApp.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import SwiftUI

@main
struct TallyApp: App {
    @State private var showSplash = true // TODO: Display once per user.

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                HomeView()
            }
        }
    }
}
