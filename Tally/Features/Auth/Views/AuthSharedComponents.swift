//
//  AuthSharedComponents.swift
//  Tally
//
//  Created by Mazen Tarek on 3/22/26.
//

import SwiftUI

struct AuthOrDivider: View {
    var body: some View {
        HStack(spacing: 0) {

            // To draw line on the left side of the OR CONTINUE WITH text.
            VStack(spacing: 0) {
                Divider()
            }

            Text("OR CONTINUE WITH")
                .font(.manrope(.medium, size: 12))
                .foregroundStyle(Color.mutedText)
                .tracking(0.5) // Letter spacing
                .lineLimit(1) // To prevent text fron wrapping
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 16)

            // To draw line on the right side of the OR CONTINUE WITH text.
            VStack(spacing: 0) {
                Divider()
            }
        }
    }
}


struct AuthSocialLoginBlock: View {
    var onGoogle: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            AuthOrDivider()

            Button(action: onGoogle) {
                HStack(spacing: 8) {
                    Image("Google")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Google")
                        .font(.manrope(.medium, size: 14))
                        .foregroundStyle(Color.heading)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
            }
            .padding(.top, 16)
        }
    }
}
