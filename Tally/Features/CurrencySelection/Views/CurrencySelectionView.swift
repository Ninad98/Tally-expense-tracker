//
//  CurrencySelectionView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/14/26.
//

import SwiftUI

struct CurrencySelectionView: View {

    let onBack: (() -> Void)?
    let onComplete: (Currency) -> Void

    @StateObject private var viewModel = CurrencySelectionViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    subtitle
                    detectLocationRow
                    currencyList
                }
                .padding(.horizontal, 16)
            }
            continueButton
        }
        .background(.white)
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.light)
    }

    private var headerBar: some View {
        ZStack {
            if let onBack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.heading)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
            }
            Text("Select Currency")
                .font(.manrope(.bold, size: 18))
                .foregroundStyle(Color.heading)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }

    private var subtitle: some View {
        Text("Choose your primary currency for transactions and reporting.")
            .font(.manrope(.regular, size: 14))
            .foregroundStyle(Color.bodyText)
            .padding(.horizontal, 6)
            .padding(.top, 8)
            .padding(.bottom, 24)
    }

    private var detectLocationRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                viewModel.detectCurrency()
            } label: {
                HStack(spacing: 16) {
                    Image("Detect-Location")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto Detect")
                            .font(.manrope(.bold, size: 16))
                            .foregroundStyle(Color.primaryBlue)

                        Text("Detect currency from your location")
                            .font(.manrope(.regular, size: 12))
                            .foregroundStyle(Color.bodyText)
                    }

                    Spacer()

                    if viewModel.isDetecting {
                        ProgressView()
                            .tint(Color.primaryBlue)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.bodyText)
                    }
                }
                .padding(16)
                .background(Color.primaryBlue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(viewModel.isDetecting)
            .padding(.bottom, 8)

            if let error = viewModel.detectionError {
                Text(error)
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.errorRose)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 16)
            }
        }
    }

    private var currencyList: some View {
        VStack(spacing: 0) {
            Text("Currencies")
                .font(.manrope(.bold, size: 12))
                .foregroundStyle(Color.mutedText)
                .tracking(0.6)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 6)
                .padding(.top, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Currency.available) { currency in
                    currencyRow(currency)
                    if currency.id != Currency.available.last?.id {
                        Divider()
                            .padding(.leading, 78)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
        .padding(.bottom, 32)
    }

    private func currencyRow(_ currency: Currency) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedCurrency = currency
            }
        } label: {
            HStack(spacing: 16) {
                Image(currency.flagAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.id)
                        .font(.manrope(.bold, size: 16))
                        .foregroundStyle(Color.heading)

                    Text(currency.name)
                        .font(.manrope(.regular, size: 12))
                        .foregroundStyle(Color.bodyText)
                }

                Spacer()

                radioButton(selected: viewModel.selectedCurrency == currency)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    private func radioButton(selected: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(selected ? Color.primaryBlue : Color.cardBorder, lineWidth: 2)
                .frame(width: 22, height: 22)

            if selected {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 12, height: 12)
            }
        }
    }

    private var continueButton: some View {
        VStack(spacing: 0) {
            Button {
                if let currency = viewModel.selectedCurrency {
                    onComplete(currency)
                }
            } label: {
                Text("Continue")
                    .font(.urbanist(.bold, size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: 320)
                    .frame(height: 60)
                    .background(
                        viewModel.selectedCurrency != nil
                            ? Color.primaryBlue
                            : Color.primaryBlue.opacity(0.4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(
                        color: Color.primaryBlue.opacity(
                            viewModel.selectedCurrency != nil ? 0.25 : 0
                        ),
                        radius: 15, x: 0, y: 10
                    )
            }
            .disabled(viewModel.selectedCurrency == nil)
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
        .background(.white)
    }
}

#Preview {
    CurrencySelectionView(onBack: {}, onComplete: { _ in })
}
