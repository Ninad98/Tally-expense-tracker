//
//  BiometricLockView.swift
//  Tally
//
//  Created by Mazen Tarek on 4/14/26.
//

import SwiftUI

struct BiometricLockView: View {

    @EnvironmentObject private var biometricManager: BiometricAuthManager

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.15))
                        .frame(width: 96, height: 96)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.primaryBlue)
                }

                Text("Welcome back to Tally")
                    .font(.urbanist(.bold, size: 24))
                    .foregroundStyle(Color.heading)

                Text("Please authenticate to continue")
                    .font(.manrope(.regular, size: 14))
                    .foregroundStyle(Color.mutedText)

                Spacer()

                // TODO: integrate apples biometric authentication when the button is pressed.
                Button {
                    Task { await unlock() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                            .font(.system(size: 18))
                        Text("Unlock")
                            .font(.manrope(.bold, size: 16))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            Task { await unlock() }
        }
    }

    private func unlock() async {
        let success = await biometricManager.authenticate()
        if success {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    biometricManager.isLocked = false
                }
            }
        }
    }
}

#Preview {
    BiometricLockView()
        .environmentObject(BiometricAuthManager())
}
