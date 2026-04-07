//
//  CategoryIconPickerSheet.swift
//  Tally
//
//  Created by Mazen Tarek on 4/4/26.
//

import SwiftUI

struct CategoryIconPickerSheet: View {

    let selectedSymbol: String
    let onPick: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 52), spacing: 12)]

    static let choices: [String] = [
        "pencil", "star.fill", "heart.fill", "fork.knife", "car.fill", "bag.fill",
        "house.fill", "film", "bolt.fill", "cross.case.fill", "airplane", "gift.fill",
        "book.fill", "gamecontroller.fill", "dumbbell.fill", "pawprint.fill", "leaf.fill",
        "creditcard.fill", "banknote.fill", "cart.fill", "bus.fill", "fuelpump.fill",
        "phone.fill", "wifi", "tv.fill", "music.note", "camera.fill", "figure.run",
        "pill.fill", "graduationcap.fill", "briefcase.fill", "cup.and.saucer.fill",
        "flame.fill", "umbrella.fill", "wrench.and.screwdriver.fill", "paintpalette.fill"
    ]

    var body: some View {
        // This allows us to add a navigation bar area to the sheet, cancel button and title Choose icon.
        NavigationStack {
            ScrollView {
                // This allows us to display the icons in a grid layout, but they are created as we scroll into view.
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Self.choices, id: \.self) { symbol in
                        Button {
                            onPick(symbol)
                        } label: {
                            ZStack {
                                // Creates a rounded rectangle that the icon would be displayed in, with an opcaity increase when selected.
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primaryBlue.opacity(symbol == selectedSymbol ? 0.2 : 0.08))
                                    .frame(width: 52, height: 52)
                                Image(systemName: symbol)
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color.primaryBlue)
                            }
                            // Border around icon, increased when selected.
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primaryBlue.opacity(symbol == selectedSymbol ? 0.55 : 0), lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(Color.pageBG)
            .navigationTitle("Choose icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
