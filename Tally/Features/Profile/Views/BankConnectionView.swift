//
//  BankConnectionView.swift
//  Tally
//
//  Created by Mazen Tarek on 4/19/26.
//

import SwiftUI

struct BankConnectionView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Link your bank to bring transactions into Tally.")
                    .font(.manrope(.medium, size: 15))
                    .foregroundStyle(Color.bodyText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                } label: {
                    Text("Connect with Plaid")
                        .font(.urbanist(.bold, size: 17))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .disabled(true)
                .opacity(0.55)

                Text("Connection is through Plaid.")
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.mutedText)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pageBG)
            .navigationTitle("Connect bank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.manrope(.medium, size: 16))
                    .foregroundStyle(Color.primaryBlue)
                }
            }
        }
    }
}

#Preview {
    BankConnectionView()
}
