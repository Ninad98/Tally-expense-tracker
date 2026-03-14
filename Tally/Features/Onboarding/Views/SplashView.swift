//
//  SplashView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/14/26.
//

import SwiftUI

struct SplashView: View {

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.primaryBlue, .primaryDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            decorativeCircles

            Image("Splash Screen")
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
        }
        .preferredColorScheme(.dark)
    }

    private var decorativeCircles: some View {
        ZStack {
            Circle()
                .fill(Color.primaryBlue.opacity(0.2))
                .frame(width: 256, height: 256)
                .blur(radius: 50)
                .offset(x: -80, y: -80)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 256, height: 256)
                .blur(radius: 50)
                .offset(x: 80, y: 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
