//
//  EditLimitsView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/30/26.
//

import FirebaseAuth
import SwiftUI

struct EditLimitsView: View {

    let existingBudget: Budget?
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var categories: [CategoryLimit] = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let firebaseService: FirebaseServiceProtocol

    init(existingBudget: Budget?, onSave: @escaping () -> Void, firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.existingBudget = existingBudget
        self.onSave = onSave
        self.firebaseService = firebaseService
        // Initialize with the existing budget's category limits, or fallback to the default values defined if there is none.
        _categories = State(initialValue: existingBudget?.categoryLimits ?? CategoryLimit.defaults)
    }

    // Calculates the total monthly budget by summing up the limits of all categories.
    private var totalMonthlyBudget: Double {
        var total = 0.0
        for category in categories {
            total += category.limit
        }
        return total
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            // To hide the scrollbar on the right side from showing
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    totalBudgetCard
                    categoryList
                    addCategoryButton
                    if let error = errorMessage {
                        Text(error)
                            .font(.manrope(.medium, size: 13))
                            .foregroundStyle(Color.errorRose)
                    }
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color.pageBG.ignoresSafeArea())
    }

    // Header section in Edit limits sheet, which contains back dismisss button, title and reset button.
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.heading)
            }

            Spacer()

            Text("Edit Budget Limits")
                .font(.urbanist(.bold, size: 18))
                .foregroundStyle(Color.heading)

            Spacer()

            // Resets the limits to the default values.
            Button("Reset") {
                categories = CategoryLimit.defaults
            }
            .font(.manrope(.bold, size: 14))
            .foregroundStyle(Color.primaryBlue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // This is for the card on the top that has title and total spent for the month.
    private var totalBudgetCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total Monthly Budget")
                .font(.manrope(.medium, size: 12))
                .foregroundStyle(Color.primaryBlue)
                .textCase(.uppercase)

            Text("\(totalMonthlyBudget.asCurrency()) / month")
                .font(.urbanist(.bold, size: 24))
                .foregroundStyle(Color.heading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    
    private var categoryList: some View {
        VStack(spacing: 12) {
            ForEach($categories) { $category in
                categoryRow(category: $category)
            }
        }
    }

    // Attribution: Slight help was used from GenAI to replicate this design UI-wise
    // From the figma design.
    private func categoryRow(category: Binding<CategoryLimit>) -> some View {
        HStack(spacing: 12) {
            
            // For the icon to be popped out on the z-axis.
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primaryBlue.opacity(0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: category.wrappedValue.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.primaryBlue)
            }

            // Name, Description, isCustom checks if it can be edited or not since it is a user created one.
            VStack(alignment: .leading, spacing: 2) {
                if category.wrappedValue.isCustom {
                    TextField("Category name", text: category.name)
                        .font(.manrope(.bold, size: 15))
                        .foregroundStyle(Color.heading)
                        .textInputAutocapitalization(.words)
                    TextField("Description", text: category.description)
                        .font(.manrope(.regular, size: 12))
                        .foregroundStyle(Color.mutedText)
                }
                else {
                    Text(category.wrappedValue.name)
                        .font(.manrope(.bold, size: 15))
                        .foregroundStyle(Color.heading)
                    Text(category.wrappedValue.description)
                        .font(.manrope(.regular, size: 12))
                        .foregroundStyle(Color.mutedText)
                }
            }
            Spacer()
            HStack(spacing: 4) {
                Text("$")
                    .font(.manrope(.medium, size: 14))
                    .foregroundStyle(Color.mutedText)
                TextField("0", value: category.limit, format: .number)
                    .font(.manrope(.bold, size: 16))
                    .foregroundStyle(Color.heading)
                    .keyboardType(.numberPad)
                    .frame(width: 70)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // TODO: Button should allow user to create a new category, select icon, and description.
    // TODO: Also allow user to delete his defined category by swiping left to delete.
    private var addCategoryButton: some View {
        Button{
            addCategory()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                Text("Add New Category")
                    .font(.manrope(.bold, size: 14))
            }
            .foregroundStyle(Color.mutedText)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var saveButton: some View {
        Button {
            saveChanges()
        } label: {
            ZStack {
                // Show progress view when it is currently saving.
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Changes")
                        .font(.urbanist(.bold, size: 18))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        // Button is disabled when it is currently saving to prevent user from spamming.
        .disabled(isSaving)
    }

    private func saveChanges() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                try await firebaseService.saveBudget(
                    uid: uid,
                    categoryLimits: categories,
                    existingBudgetId: existingBudget?.id
                )
                await MainActor.run {
                    isSaving = false
                    onSave()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func addCategory(){
        print("Add Category Button Clicked")
        categories.append(CategoryLimit(id: UUID().uuidString, name: "Edit Name", description: "Edit Description", icon: "pencil", limit: 0, isCustom: true))
    }

}

#Preview {
    EditLimitsView(existingBudget: nil, onSave: {})
}
