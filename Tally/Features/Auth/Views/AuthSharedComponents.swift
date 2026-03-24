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
            Rectangle()
                .fill(Color.cardBorder)
                .frame(height: 1)
            Text("OR CONTINUE WITH")
                .font(.manrope(.medium, size: 12))
                .foregroundStyle(Color.mutedText)
                .padding(.horizontal, 16)
            Rectangle()
                .fill(Color.cardBorder)
                .frame(height: 1)
        }
    }
}


struct AuthGoogleIcon: View {
    var body: some View {
        Text("G")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .red, .yellow, .green],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 20, height: 20)
    }
}

struct AuthSocialButtonsRow: View {
    var onGoogle: () -> Void = {}
    var onApple: () -> Void = {}

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onGoogle) {
                HStack(spacing: 8) {
                    AuthGoogleIcon()
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

            Button(action: onApple) {
                HStack(spacing: 8) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.heading)
                    Text("Apple")
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
        }
    }
}
