//
//  AddIncomeView.swift
//  ExpenseTracker
//

import SwiftUI

struct AddIncomeView: View {

    @Environment(\.dismiss) private var dismiss

    let theme: AppTheme
    let onSave: (Income) -> Void

    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedCategory: IncomeCategory = .salary
    @State private var date = Date()

    init(theme: AppTheme = .dark, onSave: @escaping (Income) -> Void) {
        self.theme = theme
        self.onSave = onSave
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && Double(amountString).map { $0 > 0 } == true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Income Details") {
                    TextField("Title (e.g. Monthly salary)", text: $title)
                        .foregroundStyle(theme.text)

                    TextField("Amount ($)", text: $amountString)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(theme.text)

                    Picker("Source", selection: $selectedCategory) {
                        ForEach(IncomeCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                    .foregroundStyle(theme.text)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .foregroundStyle(theme.text)
                }
                .listRowBackground(theme.surface)
            }
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .tint(theme.primary)
            .navigationTitle("New Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let amount = Double(amountString), isValid else {
                            return
                        }

                        let newIncome = Income(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            amount: amount,
                            date: date,
                            sourceCategory: selectedCategory
                        )

                        onSave(newIncome)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    AddIncomeView { _ in }
}
