//
//  SignUpDoneView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/22/26.
//

import SwiftUI

struct SignUpDoneView: View {
    let onLogin: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 32) {
                successMark

                VStack(spacing: 12) {
                    Text("You're all set!")
                        .font(.urbanist(.extraBold, size: 32))
                        .foregroundStyle(Color.heading)

                    Text("Your account has been created.\nPlease login with your email and password.")
                        .font(.manrope(.medium, size: 16))
                        .foregroundStyle(Color.bodyText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                }

                Button(action: onLogin) {
                    Text("Login")
                        .font(.urbanist(.bold, size: 18))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pageBG)
    }

    private var successMark: some View {
        ZStack {
            // Creating circle as background for the icon to be placed in.
            Circle()
                .fill(Color.primaryBlue.opacity(0.12))
                .frame(width: 120, height: 120)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.primaryBlue)
        }
    }
}

#Preview("Sign up - Done") {
    SignUpDoneView(onLogin: {})
}
