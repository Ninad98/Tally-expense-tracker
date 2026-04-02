//
//  AddTransactionView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/30/26.
//

import SwiftUI

struct AddTransactionView: View {

    @StateObject private var viewModel = AddTransactionViewModel()
    @Environment(\.dismiss) private var dismiss

    let onSaved: () -> Void

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        typeToggle
                        amountField
                        titleField

                        if viewModel.transactionType == .expense {
                            categoryPicker
                        }

                        datePicker
                        noteField

                        if let error = viewModel.errorMessage {
                            Label(error, systemImage: "exclamationmark.circle")
                                .font(.manrope(.regular, size: 14))
                                .foregroundStyle(Color.errorRose)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 4)
                        }

                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear { viewModel.loadCategories() }
    }


    private var navigationBar: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(.manrope(.medium, size: 16))
                .foregroundStyle(Color.mutedText)

            Spacer()

            Text("Add Transaction")
                .font(.urbanist(.bold, size: 18))
                .foregroundStyle(Color.heading)

            Spacer()

            Button("Cancel") {}
                .font(.manrope(.medium, size: 16))
                .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.pageBG)
    }


    private var typeToggle: some View {
        HStack(spacing: 0) {
            ForEach(TransactionType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.transactionType = type
                    }
                } label: {
                    Text(type == .expense ? "Expense" : "Income")
                        .font(.manrope(.bold, size: 15))
                        .foregroundStyle(viewModel.transactionType == type ? .white : Color.mutedText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            viewModel.transactionType == type ? Color.primaryBlue : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }


    private var amountField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Amount")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            HStack(spacing: 8) {
                Text("$")
                    .font(.urbanist(.bold, size: 22))
                    .foregroundStyle(Color.mutedText)

                TextField("0.00", text: $viewModel.amountText)
                    .font(.urbanist(.bold, size: 24))
                    .foregroundStyle(Color.heading)
                    .keyboardType(.decimalPad)
                    .onChange(of: viewModel.amountText) { _, _ in
                        if viewModel.amountError != nil { viewModel.amountError = nil }
                    }

                if viewModel.amountError != nil {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(Color.errorRose)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.amountError != nil ? Color.errorRose : Color.cardBorder,
                        lineWidth: viewModel.amountError != nil ? 1.5 : 1
                    )
            )

            if let error = viewModel.amountError {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.errorRose)
                    .padding(.leading, 4)
            }
        }
    }


    private var titleField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Title")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.mutedText)
                    .frame(width: 20)

                TextField(
                    "",
                    text: $viewModel.title,
                    prompt: Text("e.g. Lunch at Chipotle").foregroundStyle(Color.mutedText)
                )
                .font(.manrope(.regular, size: 16))
                .foregroundStyle(Color.heading)
                .onChange(of: viewModel.title) { _, _ in
                    if viewModel.titleError != nil { viewModel.titleError = nil }
                }

                if viewModel.titleError != nil {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(Color.errorRose)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.titleError != nil ? Color.errorRose : Color.cardBorder,
                        lineWidth: viewModel.titleError != nil ? 1.5 : 1
                    )
            )

            if let error = viewModel.titleError {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.errorRose)
                    .padding(.leading, 4)
            }
        }
    }


    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(viewModel.categories) { category in
                    Button {
                        viewModel.selectedCategoryId = category.id
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                                .font(.system(size: 14))
                            Text(category.name)
                                .font(.manrope(.medium, size: 13))
                                .lineLimit(1)
                        }
                        .foregroundStyle(
                            viewModel.selectedCategoryId == category.id ? .white : Color.heading
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            viewModel.selectedCategoryId == category.id
                                ? Color.primaryBlue : Color.white
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    viewModel.selectedCategoryId == category.id
                                        ? Color.primaryBlue : Color.cardBorder,
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
    }


    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Date")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 56)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
    }


    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Note (optional)")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                Image(systemName: "note.text")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.mutedText)
                    .frame(width: 20)

                TextField(
                    "",
                    text: $viewModel.note,
                    prompt: Text("Add a note...").foregroundStyle(Color.mutedText)
                )
                .font(.manrope(.regular, size: 16))
                .foregroundStyle(Color.heading)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
    }


    private var saveButton: some View {
        Button {
            viewModel.save {
                onSaved()
                dismiss()
            }
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Transaction")
                        .font(.urbanist(.bold, size: 18))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.primaryBlue.opacity(0.25), radius: 15, x: 0, y: 10)
        }
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    AddTransactionView(onSaved: {})
}
